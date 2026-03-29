const String fastAPIUrl = "https://alyp-kettik-backend.onrender.com";
// const String fastAPIUrl =+
//     "https://dalia-incomparable-unobviously.ngrok-free.dev";
const String uploadFileUrl = "$fastAPIUrl/recognize/file";

// Auth endpoints
const String registerUrl = "$fastAPIUrl/auth/register";
const String loginUrl = "$fastAPIUrl/auth/login";
const String meUrl = "$fastAPIUrl/auth/me";

// Session endpoints
const String sessionEnterUrl = "$fastAPIUrl/sessions/enter";
const String sessionActiveUrl = "$fastAPIUrl/sessions/active";
const String sessionCompleteUrl = "$fastAPIUrl/sessions/complete";
String sessionCartUrl(String sessionId) =>
    "$fastAPIUrl/sessions/$sessionId/cart";

// Products endpoints
const String productsUrl = "$fastAPIUrl/products";
