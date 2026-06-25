// Eskiz.uz SMS OTP integration — stubbed for now.
// Real integration: authenticate against https://notify.eskiz.uz/api/auth/login
// using ESKIZ_EMAIL/ESKIZ_PASSWORD, cache the bearer token, then POST to
// /api/message/sms/send with the recipient phone + message text.
export async function sendOTP(phone: string, code: string): Promise<void> {
  console.log(`[SMS] OTP kodi ${phone} raqamiga yuborildi: ${code}`);
}
