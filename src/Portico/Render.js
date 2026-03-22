export const unsafeTake = (count) => (value) => value.slice(0, count);

export const escapeHtml = (value) =>
  value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/\"/g, "&quot;")
    .replace(/'/g, "&#39;");

export const absoluteUrl = (baseUrl) => (path) => {
  const normalizedBaseUrl = baseUrl.endsWith("/") ? baseUrl : `${baseUrl}/`;
  return new URL(path, normalizedBaseUrl).toString();
};

export const relativeHref = (fromPath) => (toPath) => {
  const fromParts = fromPath.split("/").filter(Boolean);
  const toParts = toPath.split("/").filter(Boolean);
  const fromDirectory = fromParts.slice(0, -1);

  let sharedPrefixLength = 0;
  while (
    sharedPrefixLength < fromDirectory.length &&
    sharedPrefixLength < toParts.length &&
    fromDirectory[sharedPrefixLength] === toParts[sharedPrefixLength]
  ) {
    sharedPrefixLength += 1;
  }

  const upwardSegments = new Array(
    fromDirectory.length - sharedPrefixLength
  ).fill("..");
  const downwardSegments = toParts.slice(sharedPrefixLength);
  const relativeSegments = upwardSegments.concat(downwardSegments);

  return relativeSegments.length === 0 ? "." : relativeSegments.join("/");
};
