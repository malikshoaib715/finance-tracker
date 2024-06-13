// Network-first for pages, with a cached offline page as the fallback.
// Only GET navigations are handled; everything else goes straight to the network.
const CACHE = "finance-tracker-v1"
const OFFLINE_URL = "/offline.html"

self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(CACHE).then((cache) => cache.addAll([ OFFLINE_URL, "/icon.svg" ])))
  self.skipWaiting()
})

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) => Promise.all(keys.filter((key) => key !== CACHE).map((key) => caches.delete(key))))
  )
  self.clients.claim()
})

self.addEventListener("fetch", (event) => {
  if (event.request.mode !== "navigate") return

  event.respondWith(fetch(event.request).catch(() => caches.match(OFFLINE_URL)))
})
