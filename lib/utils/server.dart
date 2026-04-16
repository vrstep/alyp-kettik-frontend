// Local backend via Tailscale Funnel (public HTTPS, no cold starts)
const String fastAPIUrl = "https://rio.tail8c3fdb.ts.net";

// Cloud fallback (Render — has cold starts):
// const String fastAPIUrl = "https://alyp-kettik-backend.onrender.com";
const String uploadFileUrl = "$fastAPIUrl/recognize/file";

// Auth endpoints
const String registerUrl = "$fastAPIUrl/auth/register";
const String loginUrl = "$fastAPIUrl/auth/login";
const String meUrl = "$fastAPIUrl/auth/me";

// Session endpoints
const String sessionEnterUrl = "$fastAPIUrl/sessions/enter";
const String sessionActiveUrl = "$fastAPIUrl/sessions/active";
const String sessionCompleteUrl = "$fastAPIUrl/sessions/complete";
const String entryQrUrl = "$fastAPIUrl/sessions/entry-qr";
String sessionCartUrl(String sessionId) =>
    "$fastAPIUrl/sessions/$sessionId/cart";

// Products endpoints
const String productsUrl = "$fastAPIUrl/products";
