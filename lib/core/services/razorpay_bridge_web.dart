import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('eval')
external JSAny? _jsEval(JSString code);

void _ensureJsBridgeLoaded() {
  const initScript = r'''
    (function() {
      // 1. Inject Razorpay checkout.js script if not present
      if (!window.Razorpay && !document.getElementById('razorpay-checkout-script')) {
        var script = document.createElement('script');
        script.id = 'razorpay-checkout-script';
        script.src = 'https://checkout.razorpay.com/v1/checkout.js';
        script.async = true;
        document.head.appendChild(script);
      }

      // 2. Define or update window.openRazorpayWebCheckout
      window.openRazorpayWebCheckout = function(optionsJson, successCallback, failureCallback) {
        var attempts = 0;
        function launch() {
          if (typeof Razorpay === 'undefined') {
            attempts++;
            if (attempts > 30) { // waited 4.5 seconds
              if (failureCallback) failureCallback('Razorpay SDK failed to load from CDN. Please check network connection.');
              return;
            }
            setTimeout(launch, 150);
            return;
          }

          try {
            var options = typeof optionsJson === 'string' ? JSON.parse(optionsJson) : optionsJson;
            options.handler = function(response) {
              if (successCallback) {
                successCallback(response.razorpay_payment_id || '', response.razorpay_order_id || '', response.razorpay_signature || '');
              }
            };
            options.modal = {
              ondismiss: function() {
                if (failureCallback) failureCallback('Payment cancelled: checkout closed by user');
              }
            };
            var rzp = new Razorpay(options);
            rzp.on('payment.failed', function(response) {
              var msg = (response && response.error && response.error.description) ? response.error.description : 'Payment failed';
              if (failureCallback) failureCallback(msg);
            });
            rzp.open();
          } catch (e) {
            if (failureCallback) failureCallback('Error launching Razorpay: ' + e);
          }
        }
        launch();
      };
    })();
  ''';

  try {
    _jsEval(initScript.toJS);
  } catch (e) {
    // eval error fallback
  }
}

void openWebRazorpay({
  required Map<String, dynamic> options,
  required void Function(String paymentId, String orderId, String signature) onSuccess,
  required void Function(String errorMessage) onFailure,
}) {
  _ensureJsBridgeLoaded();

  final jsonString = jsonEncode(options);

  final successJS = (JSString paymentId, JSString orderId, JSString signature) {
    onSuccess(paymentId.toDart, orderId.toDart, signature.toDart);
  }.toJS;

  final failureJS = (JSString errorMessage) {
    onFailure(errorMessage.toDart);
  }.toJS;

  try {
    if (globalContext.has('openRazorpayWebCheckout')) {
      globalContext.callMethod(
        'openRazorpayWebCheckout'.toJS,
        jsonString.toJS,
        successJS,
        failureJS,
      );
    } else {
      onFailure('Unable to load Razorpay Web bridge.');
    }
  } catch (e) {
    onFailure('Razorpay initialization exception: $e');
  }
}

