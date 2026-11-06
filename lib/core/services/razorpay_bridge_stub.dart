/// No-op on native mobile platforms (handled by native Razorpay SDK)
void openWebRazorpay({
  required Map<String, dynamic> options,
  required void Function(String paymentId, String orderId, String signature) onSuccess,
  required void Function(String errorMessage) onFailure,
}) {}
