(define-configuration nyxt/mode/proxy:proxy-mode
  ((nyxt/mode/proxy:proxy (make-instance 'proxy
                                         :url (quri:uri "socks5://localhost:9050")
                                         :allowlist '("localhost" "localhost:8080")
                                         :proxied-downloads-p t))))
