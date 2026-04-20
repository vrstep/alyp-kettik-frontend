// Local backend via Tailscale Funnel (public HTTPS, no cold starts)
const String fastAPIUrl = "https://rio.tail8c3fdb.ts.net";

// Cloud fallback (Render — has cold starts):
// const String fastAPIUrl = "https://alyp-kettik-backend.onrender.com";
const String uploadFileUrl = "$fastAPIUrl/recognize/file";

// Auth endpoints
const String registerUrl = "$fastAPIUrl/auth/register";
const String loginUrl = "$fastAPIUrl/auth/login";
const String meUrl = "$fastAPIUrl/auth/me";
const String updateProfileUrl = "$fastAPIUrl/auth/profile";
const String changePasswordUrl = "$fastAPIUrl/auth/password";

// Session endpoints
const String sessionEnterUrl = "$fastAPIUrl/sessions/enter";
const String sessionActiveUrl = "$fastAPIUrl/sessions/active";
const String sessionCompleteUrl = "$fastAPIUrl/sessions/complete";
const String entryQrUrl = "$fastAPIUrl/sessions/entry-qr";
String sessionCartUrl(String sessionId) =>
    "$fastAPIUrl/sessions/$sessionId/cart";

// Products endpoints
const String productsUrl = "$fastAPIUrl/products";

// Payment endpoints
const String paymentMethodsUrl = "$fastAPIUrl/payment/methods";
const String paymentPayUrl = "$fastAPIUrl/payment/pay";
const String paymentOrdersUrl = "$fastAPIUrl/payment/orders";
String paymentOrderDetailUrl(String orderId) =>
    "$fastAPIUrl/payment/orders/$orderId";
String paymentMethodDefaultUrl(int id) =>
    "$fastAPIUrl/payment/methods/$id/default";
String paymentMethodDeleteUrl(int id) => "$fastAPIUrl/payment/methods/$id";
