// =============================================================
// payments.js — your Payme & Click merchant settings
// =============================================================
// These values come from the .env file. Right now they hold harmless
// PLACEHOLDER/TEST values so everything runs and can be tested with fake
// data. When you get real merchant accounts, you only change the values
// in .env — you never edit this file. See PAYME_CLICK_SETUP.md.
// =============================================================

module.exports = {
  payme: {
    // Payme logs in to your webhook with the username "Paycom" and this key
    // as the password (Basic auth). Payme gives you a TEST key and a LIVE key.
    merchantId: process.env.PAYME_MERCHANT_ID || 'TEST_PAYME_MERCHANT_ID',
    key: process.env.PAYME_KEY || 'TEST_PAYME_KEY',
    // The name of the field inside Payme's "account" object that carries our
    // order id. You set this same word in the Payme merchant cabinet.
    accountField: process.env.PAYME_ACCOUNT_FIELD || 'order_id',
    // Where buyers are sent to pay (Payme checkout). Sandbox vs production.
    checkoutBaseUrl: process.env.PAYME_CHECKOUT_URL || 'https://checkout.paycom.uz',
  },

  click: {
    // Click identifies your shop with a service id + merchant id, and signs
    // every callback using your SECRET KEY (we verify that signature).
    serviceId: process.env.CLICK_SERVICE_ID || 'TEST_CLICK_SERVICE_ID',
    merchantId: process.env.CLICK_MERCHANT_ID || 'TEST_CLICK_MERCHANT_ID',
    secretKey: process.env.CLICK_SECRET_KEY || 'TEST_CLICK_SECRET_KEY',
    checkoutBaseUrl: process.env.CLICK_CHECKOUT_URL || 'https://my.click.uz/services/pay',
  },
};
