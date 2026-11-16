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

      // 3. Inject Cashfree JS v3 script if not present
      if (!window.Cashfree && !document.getElementById('cashfree-checkout-script')) {
        var cfScript = document.createElement('script');
        cfScript.id = 'cashfree-checkout-script';
        cfScript.src = 'https://sdk.cashfree.com/js/v3/cashfree.js';
        cfScript.async = true;
        document.head.appendChild(cfScript);
      }

      // 4. Define or update window.openCashfreeWebCheckout
      window.openCashfreeWebCheckout = function(optionsJson, successCallback, failureCallback) {
        var attempts = 0;
        function launch() {
          if (typeof Cashfree === 'undefined') {
            attempts++;
            if (attempts > 30) {
              if (failureCallback) failureCallback('Cashfree SDK failed to load from CDN. Please check network connection.');
              return;
            }
            setTimeout(launch, 150);
            return;
          }

          try {
            var options = typeof optionsJson === 'string' ? JSON.parse(optionsJson) : optionsJson;
            var paymentSessionId = options.paymentSessionId;
            var orderId = options.orderId;
            var isProduction = options.isProduction;

            var mode = isProduction ? 'production' : 'sandbox';
            var cashfree = Cashfree({ mode: mode });

            cashfree.checkout({
              paymentSessionId: paymentSessionId,
              redirectTarget: '_modal'
            }).then(function(result) {
              if (result && result.error) {
                if (failureCallback) failureCallback(result.error.message || 'Cashfree payment was cancelled or failed');
              } else if (result && result.paymentDetails) {
                if (successCallback) successCallback(orderId);
              }
            }).catch(function(err) {
              if (failureCallback) failureCallback('Cashfree checkout error: ' + err);
            });
          } catch (e) {
            if (failureCallback) failureCallback('Error launching Cashfree: ' + e);
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

void openWebCashfree({
  required String paymentSessionId,
  required String orderId,
  required bool isProd,
  required void Function(String orderId) onSuccess,
  required void Function(String errorMessage) onFailure,
}) {
  _ensureJsBridgeLoaded();

  final successJS = (JSString cfOrderId) {
    onSuccess(cfOrderId.toDart);
  }.toJS;

  final failureJS = (JSString errorMessage) {
    onFailure(errorMessage.toDart);
  }.toJS;

  final payloadJson = jsonEncode({
    'paymentSessionId': paymentSessionId,
    'orderId': orderId,
    'isProduction': isProd,
  });

  try {
    if (globalContext.has('openCashfreeWebCheckout')) {
      globalContext.callMethod(
        'openCashfreeWebCheckout'.toJS,
        payloadJson.toJS,
        successJS,
        failureJS,
      );
    } else {
      onFailure('Unable to load Cashfree Web bridge.');
    }
  } catch (e) {
    onFailure('Cashfree initialization exception: $e');
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

