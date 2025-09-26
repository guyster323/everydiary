// Service Worker for EveryDiary PWA
// Version: 2.0.0
const CACHE_NAME = 'everydiary-v2.0.0';
const STATIC_CACHE_NAME = 'everydiary-static-v2.0.0';
const DYNAMIC_CACHE_NAME = 'everydiary-dynamic-v2.0.0';
const DATA_CACHE_NAME = 'everydiary-data-v2.0.0';

// 캐시할 정적 자산들
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  '/icons/Icon-72.png',
  '/icons/Icon-96.png',
  '/icons/Icon-144.png',
  '/icons/Icon-384.png',
  '/splash.html',
  // Flutter 웹 자산들
  '/flutter_bootstrap.js',
  '/flutter.js',
  '/canvaskit/',
  '/assets/',
];

// 캐시 만료 시간 (밀리초)
const CACHE_EXPIRY = {
  static: 7 * 24 * 60 * 60 * 1000, // 7일
  dynamic: 24 * 60 * 60 * 1000, // 1일
  data: 60 * 60 * 1000, // 1시간
};

// 캐시 크기 제한 (바이트)
const CACHE_SIZE_LIMITS = {
  static: 30 * 1024 * 1024, // 30MB
  dynamic: 15 * 1024 * 1024, // 15MB
  data: 5 * 1024 * 1024, // 5MB
};

// API 엔드포인트들 (동적 캐싱 대상)
const API_PATTERNS = [
  '/api/',
  '/supabase/',
  '/firebase/',
];

// Service Worker 설치 이벤트
self.addEventListener('install', (event) => {
  console.log('[SW] Installing Service Worker...');

  event.waitUntil(
    caches.open(STATIC_CACHE_NAME)
      .then((cache) => {
        console.log('[SW] Caching static assets');
        return cache.addAll(STATIC_ASSETS);
      })
      .then(() => {
        console.log('[SW] Static assets cached successfully');
        return self.skipWaiting();
      })
      .catch((error) => {
        console.error('[SW] Failed to cache static assets:', error);
      })
  );
});

// Service Worker 활성화 이벤트
self.addEventListener('activate', (event) => {
  console.log('[SW] Activating Service Worker...');

  event.waitUntil(
    caches.keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            // 오래된 캐시 삭제
            if (cacheName !== STATIC_CACHE_NAME &&
                cacheName !== DYNAMIC_CACHE_NAME &&
                cacheName !== DATA_CACHE_NAME) {
              console.log('[SW] Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      })
      .then(() => {
        console.log('[SW] Service Worker activated');
        return self.clients.claim();
      })
      .then(() => {
        // 캐시 정리 및 크기 제한 적용
        return cleanupExpiredCaches();
      })
  );
});

// 네트워크 요청 가로채기
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // GET 요청만 처리
  if (request.method !== 'GET') {
    return;
  }

  // 정적 자산에 대한 Cache-First 전략
  if (isStaticAsset(request.url)) {
    event.respondWith(cacheFirst(request, 'static'));
    return;
  }

  // API 요청에 대한 Network-First 전략
  if (isApiRequest(request.url)) {
    event.respondWith(networkFirst(request, 'dynamic'));
    return;
  }

  // 이미지 요청에 대한 Stale-While-Revalidate 전략
  if (isImageRequest(request.url)) {
    event.respondWith(staleWhileRevalidate(request, 'dynamic'));
    return;
  }

  // 데이터 요청에 대한 Cache-First 전략
  if (isDataRequest(request.url)) {
    event.respondWith(cacheFirst(request, 'data'));
    return;
  }

  // 기본적으로 Network-First 전략
  event.respondWith(networkFirst(request, 'dynamic'));
});

// 백그라운드 동기화
self.addEventListener('sync', (event) => {
  console.log('[SW] Background sync triggered:', event.tag);

  if (event.tag === 'background-sync') {
    event.waitUntil(doBackgroundSync());
  }
});

// 푸시 알림
self.addEventListener('push', (event) => {
  console.log('[SW] Push notification received');

  const options = {
    body: event.data ? event.data.text() : '새로운 알림이 있습니다.',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    vibrate: [200, 100, 200],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    },
    actions: [
      {
        action: 'explore',
        title: '확인하기',
        icon: '/icons/Icon-192.png'
      },
      {
        action: 'close',
        title: '닫기',
        icon: '/icons/Icon-192.png'
      }
    ]
  };

  event.waitUntil(
    self.registration.showNotification('EveryDiary', options)
  );
});

// 알림 클릭 처리
self.addEventListener('notificationclick', (event) => {
  console.log('[SW] Notification clicked:', event.action);

  event.notification.close();

  if (event.action === 'explore') {
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});

// 캐싱 전략들
async function cacheFirst(request, cacheType) {
  try {
    const cacheName = getCacheName(cacheType);
    const cachedResponse = await caches.match(request);

    if (cachedResponse) {
      // 캐시 만료 확인
      if (await isCacheExpired(cachedResponse, cacheType)) {
        const cache = await caches.open(cacheName);
        await cache.delete(request);
        console.log('[SW] Expired cache deleted:', request.url);
      } else {
        console.log('[SW] Serving from cache:', request.url);
        return cachedResponse;
      }
    }

    const networkResponse = await fetch(request);
    if (networkResponse.ok) {
      const cache = await caches.open(cacheName);
      const responseWithMetadata = await addCacheMetadata(networkResponse, cacheType);
      cache.put(request, responseWithMetadata.clone());
    }

    return networkResponse;
  } catch (error) {
    console.error('[SW] Cache-first failed:', error);
    return new Response('Offline', { status: 503 });
  }
}

async function networkFirst(request, cacheType) {
  try {
    const networkResponse = await fetch(request);

    if (networkResponse.ok) {
      const cacheName = getCacheName(cacheType);
      const cache = await caches.open(cacheName);
      const responseWithMetadata = await addCacheMetadata(networkResponse, cacheType);
      cache.put(request, responseWithMetadata.clone());
    }

    return networkResponse;
  } catch (error) {
    console.log('[SW] Network failed, trying cache:', request.url);
    const cachedResponse = await caches.match(request);

    if (cachedResponse) {
      // 캐시 만료 확인
      if (await isCacheExpired(cachedResponse, cacheType)) {
        const cacheName = getCacheName(cacheType);
        const cache = await caches.open(cacheName);
        await cache.delete(request);
        console.log('[SW] Expired cache deleted:', request.url);
      } else {
        return cachedResponse;
      }
    }

    return new Response('Offline', { status: 503 });
  }
}

async function staleWhileRevalidate(request, cacheType) {
  const cacheName = getCacheName(cacheType);
  const cache = await caches.open(cacheName);
  const cachedResponse = await cache.match(request);

  const fetchPromise = fetch(request).then(async (networkResponse) => {
    if (networkResponse.ok) {
      const responseWithMetadata = await addCacheMetadata(networkResponse, cacheType);
      cache.put(request, responseWithMetadata.clone());
    }
    return networkResponse;
  });

  return cachedResponse || fetchPromise;
}

// 백그라운드 동기화 작업
async function doBackgroundSync() {
  try {
    console.log('[SW] Performing background sync...');

    // 오프라인 큐에서 대기 중인 작업들 처리
    const offlineQueue = await getOfflineQueue();

    for (const item of offlineQueue) {
      try {
        await processOfflineItem(item);
        await removeFromOfflineQueue(item.id);
      } catch (error) {
        console.error('[SW] Failed to process offline item:', error);
      }
    }

    console.log('[SW] Background sync completed');
  } catch (error) {
    console.error('[SW] Background sync failed:', error);
  }
}

// 오프라인 큐 관리
async function getOfflineQueue() {
  try {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open('EveryDiaryDB', 1);

      request.onsuccess = (event) => {
        const db = event.target.result;
        const transaction = db.transaction(['offlineQueue'], 'readonly');
        const store = transaction.objectStore('offlineQueue');
        const getAllRequest = store.getAll();

        getAllRequest.onsuccess = () => {
          resolve(getAllRequest.result || []);
        };

        getAllRequest.onerror = () => {
          reject(getAllRequest.error);
        };
      };

      request.onerror = () => {
        reject(request.error);
      };
    });
  } catch (error) {
    console.error('[SW] Failed to get offline queue:', error);
    return [];
  }
}

async function processOfflineItem(item) {
  try {
    console.log('[SW] Processing offline item:', item.type);

    // 아이템 타입에 따른 처리
    switch (item.type) {
      case 'diary_create':
        await processDiaryCreate(item.data);
        break;
      case 'diary_update':
        await processDiaryUpdate(item.data);
        break;
      case 'diary_delete':
        await processDiaryDelete(item.data);
        break;
      case 'settings_update':
        await processSettingsUpdate(item.data);
        break;
      default:
        console.warn('[SW] Unknown item type:', item.type);
    }

    console.log('[SW] Successfully processed offline item:', item.type);
  } catch (error) {
    console.error('[SW] Failed to process offline item:', error);
    throw error;
  }
}

// 일기 생성 처리
async function processDiaryCreate(data) {
  // 실제 API 호출 구현
  console.log('[SW] Creating diary:', data.title);

  // 임시 구현 - 실제 API 호출 시뮬레이션
  await new Promise(resolve => setTimeout(resolve, 1000));
}

// 일기 업데이트 처리
async function processDiaryUpdate(data) {
  // 실제 API 호출 구현
  console.log('[SW] Updating diary:', data.id);

  // 임시 구현 - 실제 API 호출 시뮬레이션
  await new Promise(resolve => setTimeout(resolve, 800));
}

// 일기 삭제 처리
async function processDiaryDelete(data) {
  // 실제 API 호출 구현
  console.log('[SW] Deleting diary:', data.id);

  // 임시 구현 - 실제 API 호출 시뮬레이션
  await new Promise(resolve => setTimeout(resolve, 600));
}

// 설정 업데이트 처리
async function processSettingsUpdate(data) {
  // 실제 API 호출 구현
  console.log('[SW] Updating settings:', data.key);

  // 임시 구현 - 실제 API 호출 시뮬레이션
  await new Promise(resolve => setTimeout(resolve, 400));
}

async function removeFromOfflineQueue(id) {
  try {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open('EveryDiaryDB', 1);

      request.onsuccess = (event) => {
        const db = event.target.result;
        const transaction = db.transaction(['offlineQueue'], 'readwrite');
        const store = transaction.objectStore('offlineQueue');
        const deleteRequest = store.delete(id);

        deleteRequest.onsuccess = () => {
          console.log('[SW] Removed item from queue:', id);
          resolve();
        };

        deleteRequest.onerror = () => {
          reject(deleteRequest.error);
        };
      };

      request.onerror = () => {
        reject(request.error);
      };
    });
  } catch (error) {
    console.error('[SW] Failed to remove item from queue:', error);
  }
}

// 유틸리티 함수들
function isStaticAsset(url) {
  return STATIC_ASSETS.some(asset => url.includes(asset)) ||
         url.includes('/assets/') ||
         url.includes('/canvaskit/') ||
         url.includes('/flutter.js') ||
         url.includes('/flutter_bootstrap.js');
}

function isApiRequest(url) {
  return API_PATTERNS.some(pattern => url.includes(pattern));
}

function isImageRequest(url) {
  return /\.(jpg|jpeg|png|gif|webp|svg)$/i.test(url);
}

function isDataRequest(url) {
  return url.includes('/data/') || url.includes('/user/') || url.includes('/diary/');
}

// 캐시 타입에 따른 캐시 이름 반환
function getCacheName(cacheType) {
  switch (cacheType) {
    case 'static':
      return STATIC_CACHE_NAME;
    case 'dynamic':
      return DYNAMIC_CACHE_NAME;
    case 'data':
      return DATA_CACHE_NAME;
    default:
      return DYNAMIC_CACHE_NAME;
  }
}

// 캐시 메타데이터 추가
async function addCacheMetadata(response, cacheType) {
  const metadata = {
    timestamp: Date.now(),
    type: cacheType,
    expiry: CACHE_EXPIRY[cacheType] || CACHE_EXPIRY.dynamic,
  };

  const headers = new Headers(response.headers);
  headers.set('x-cache-metadata', JSON.stringify(metadata));

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: headers,
  });
}

// 캐시 만료 확인
async function isCacheExpired(response, cacheType) {
  try {
    const metadataHeader = response.headers.get('x-cache-metadata');
    if (metadataHeader) {
      const metadata = JSON.parse(metadataHeader);
      const now = Date.now();
      const expiry = metadata.expiry || CACHE_EXPIRY[cacheType] || CACHE_EXPIRY.dynamic;
      return (now - metadata.timestamp) > expiry;
    }
  } catch (error) {
    console.error('[SW] Cache expiry check failed:', error);
  }
  return true; // 메타데이터가 없으면 만료된 것으로 간주
}

// 만료된 캐시 정리
async function cleanupExpiredCaches() {
  try {
    console.log('[SW] Cleaning up expired caches...');

    const cacheNames = [STATIC_CACHE_NAME, DYNAMIC_CACHE_NAME, DATA_CACHE_NAME];

    for (const cacheName of cacheNames) {
      const cache = await caches.open(cacheName);
      const requests = await cache.keys();

      for (const request of requests) {
        const response = await cache.match(request);
        if (response) {
          const cacheType = getCacheTypeFromName(cacheName);
          if (await isCacheExpired(response, cacheType)) {
            await cache.delete(request);
            console.log('[SW] Expired cache deleted:', request.url);
          }
        }
      }
    }

    // 캐시 크기 제한 적용
    await enforceCacheSizeLimits();

    console.log('[SW] Cache cleanup completed');
  } catch (error) {
    console.error('[SW] Cache cleanup failed:', error);
  }
}

// 캐시 이름에서 타입 추출
function getCacheTypeFromName(cacheName) {
  if (cacheName.includes('static')) return 'static';
  if (cacheName.includes('data')) return 'data';
  return 'dynamic';
}

// 캐시 크기 제한 적용
async function enforceCacheSizeLimits() {
  try {
    const cacheLimits = [
      { name: STATIC_CACHE_NAME, limit: CACHE_SIZE_LIMITS.static },
      { name: DYNAMIC_CACHE_NAME, limit: CACHE_SIZE_LIMITS.dynamic },
      { name: DATA_CACHE_NAME, limit: CACHE_SIZE_LIMITS.data },
    ];

    for (const { name, limit } of cacheLimits) {
      const cache = await caches.open(name);
      const currentSize = await getCacheSize(cache);

      if (currentSize > limit) {
        await trimCacheToSize(cache, limit);
        console.log(`[SW] Cache trimmed: ${name} (${(currentSize / 1024 / 1024).toFixed(2)}MB -> ${(limit / 1024 / 1024).toFixed(2)}MB)`);
      }
    }
  } catch (error) {
    console.error('[SW] Cache size enforcement failed:', error);
  }
}

// 캐시 크기 계산
async function getCacheSize(cache) {
  let totalSize = 0;
  const requests = await cache.keys();

  for (const request of requests) {
    const response = await cache.match(request);
    if (response) {
      const body = await response.arrayBuffer();
      totalSize += body.byteLength;
    }
  }

  return totalSize;
}

// 캐시를 지정된 크기로 트림
async function trimCacheToSize(cache, maxSize) {
  const requests = await cache.keys();
  const entries = [];

  // 각 요청의 크기와 타임스탬프 수집
  for (const request of requests) {
    const response = await cache.match(request);
    if (response) {
      const body = await response.arrayBuffer();
      const size = body.byteLength;
      const timestamp = getCacheTimestamp(response);
      entries.push({ timestamp, size, request });
    }
  }

  // 타임스탬프 순으로 정렬 (오래된 것부터)
  entries.sort((a, b) => a.timestamp - b.timestamp);

  let currentSize = entries.reduce((sum, entry) => sum + entry.size, 0);

  // 크기 제한에 도달할 때까지 오래된 항목 삭제
  for (const entry of entries) {
    if (currentSize <= maxSize) break;

    await cache.delete(entry.request);
    currentSize -= entry.size;
  }
}

// 캐시 타임스탬프 가져오기
function getCacheTimestamp(response) {
  try {
    const metadataHeader = response.headers.get('x-cache-metadata');
    if (metadataHeader) {
      const metadata = JSON.parse(metadataHeader);
      return metadata.timestamp || 0;
    }
  } catch (error) {
    console.error('[SW] Cache timestamp extraction failed:', error);
  }
  return 0;
}

// 메시지 처리
self.addEventListener('message', (event) => {
  console.log('[SW] Message received:', event.data);

  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }

  if (event.data && event.data.type === 'GET_VERSION') {
    event.ports[0].postMessage({ version: CACHE_NAME });
  }
});

console.log('[SW] Service Worker script loaded');
