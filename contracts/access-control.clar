;; Access Control Contract
;; Manages permissions for viewing evidence

(define-map access-rights
  { case-id: uint, principal: principal }
  {
    read: bool,
    write: bool,
    admin: bool,
    granted-by: principal,
    granted-at: uint
  }
)

(define-public (grant-access
    (case-id uint)
    (user principal)
    (read bool)
    (write bool)
    (admin bool))
  (let (
    (caller-rights (default-to
      { read: false, write: false, admin: false, granted-by: tx-sender, granted-at: u0 }
      (map-get? access-rights { case-id: case-id, principal: tx-sender })))
    )
    (begin
      (asserts! (get admin caller-rights) (err u1))
      (map-set access-rights { case-id: case-id, principal: user } {
        read: read,
        write: write,
        admin: admin,
        granted-by: tx-sender,
        granted-at: block-height
      })
      (ok true)
    )
  )
)

(define-public (initialize-case-access (case-id uint))
  (begin
    (map-set access-rights { case-id: case-id, principal: tx-sender } {
      read: true,
      write: true,
      admin: true,
      granted-by: tx-sender,
      granted-at: block-height
    })
    (ok true)
  )
)

(define-public (revoke-access (case-id uint) (user principal))
  (let (
    (caller-rights (default-to
      { read: false, write: false, admin: false, granted-by: tx-sender, granted-at: u0 }
      (map-get? access-rights { case-id: case-id, principal: tx-sender })))
    )
    (begin
      (asserts! (get admin caller-rights) (err u1))
      (map-delete access-rights { case-id: case-id, principal: user })
      (ok true)
    )
  )
)

(define-read-only (check-access (case-id uint) (user principal))
  (default-to
    { read: false, write: false, admin: false, granted-by: user, granted-at: u0 }
    (map-get? access-rights { case-id: case-id, principal: user })
  )
)

(define-read-only (has-read-access (case-id uint) (user principal))
  (get read (check-access case-id user))
)

(define-read-only (has-write-access (case-id uint) (user principal))
  (get write (check-access case-id user))
)

(define-read-only (has-admin-access (case-id uint) (user principal))
  (get admin (check-access case-id user))
)
