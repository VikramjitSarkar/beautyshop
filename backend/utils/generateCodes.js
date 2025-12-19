export const generateReferralCodes = (count) => {
  const codes = new Set();
  while (codes.size < count) {
    const code = Math.random().toString(36).substring(2, 10).toUpperCase(); // e.g. "GHT9K8P1"
    codes.add(code);
  }
  return [...codes];
};
