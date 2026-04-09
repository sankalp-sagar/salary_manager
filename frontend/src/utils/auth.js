export function isAuthenticated() {
  return Boolean(localStorage.getItem('authToken'));
}

export function signOut() {
  localStorage.removeItem('authToken');
}
