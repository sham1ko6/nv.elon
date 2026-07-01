export const API_ROOT = 'https://elon-backend-jh1a.onrender.com';
const API_BASE = `${API_ROOT}/api`;

let authToken: string | null = localStorage.getItem('authToken');

export function setAuthToken(token: string | null) {
  authToken = token;
  if (token) localStorage.setItem('authToken', token);
  else localStorage.removeItem('authToken');
}

async function request(path: string, options: RequestInit = {}) {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string> || {}),
  };
  if (authToken) headers['Authorization'] = `Bearer ${authToken}`;

  const res = await fetch(`${API_BASE}${path}`, { ...options, headers });
  if (!res.ok) {
    const error = await res.json().catch(() => ({ error: 'Network error' }));
    throw new Error(error.error || `HTTP ${res.status}`);
  }
  return res.json();
}

export const api = {
  // Auth
  register: (data: { name: string; phone: string; password: string }) =>
    request('/auth/register', { method: 'POST', body: JSON.stringify(data) }),
  login: (data: { phone: string; password: string }) =>
    request('/auth/login', { method: 'POST', body: JSON.stringify(data) }),
  requestOtp: (phone: string) =>
    request('/auth/otp/request', { method: 'POST', body: JSON.stringify({ phone }) }),
  verifyOtp: (phone: string, code: string) =>
    request('/auth/otp/verify', { method: 'POST', body: JSON.stringify({ phone, code }) }),
  me: () => request('/auth/me'),

  // Categories
  getCategories: () => request('/categories'),

  // Listings
  getListings: (params?: Record<string, string>) => {
    const qs = params ? '?' + new URLSearchParams(params).toString() : '';
    return request(`/listings${qs}`);
  },
  getListing: (id: string | number) => request(`/listings/${id}`),
  createListing: (data: any) =>
    request('/listings', { method: 'POST', body: JSON.stringify(data) }),
  updateListing: (id: string | number, data: any) =>
    request(`/listings/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
  deleteListing: (id: string | number) =>
    request(`/listings/${id}`, { method: 'DELETE' }),
  getMyListings: () => request('/me/listings'),
  contactListing: (id: string | number) =>
    request(`/listings/${id}/contact`, { method: 'POST' }),

  // Favorites
  getFavorites: () => request('/me/favorites'),
  addFavorite: (id: string | number) =>
    request(`/listings/${id}/favorite`, { method: 'POST' }),
  removeFavorite: (id: string | number) =>
    request(`/listings/${id}/favorite`, { method: 'DELETE' }),

  // Plans & Subscriptions
  getPlans: () => request('/plans'),
  createSubscription: (planId: number, provider: string) =>
    request('/subscriptions', { method: 'POST', body: JSON.stringify({ plan_id: planId, provider }) }),
  getMySubscription: () => request('/me/subscription'),
  getMyOrders: () => request('/me/orders'),
  initPayment: (orderId: string | number, provider: string) =>
    request('/payments/init', { method: 'POST', body: JSON.stringify({ order_id: orderId, provider }) }),

  // Image upload
  uploadImages: async (listingId: string | number, files: File[]) => {
    const formData = new FormData();
    files.forEach(f => formData.append('images', f));
    const headers: Record<string, string> = {};
    if (authToken) headers['Authorization'] = `Bearer ${authToken}`;
    const res = await fetch(`${API_BASE}/listings/${listingId}/images`, {
      method: 'POST', headers, body: formData,
    });
    if (!res.ok) throw new Error('Upload failed');
    return res.json();
  },
};
