;; Postpartum Depression Screening Contract
;; Identifies and provides support for maternal mental health

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-MOTHER-NOT-FOUND (err u501))
(define-constant ERR-INVALID-INPUT (err u502))
(define-constant ERR-SCREENING-NOT-FOUND (err u503))
(define-constant ERR-SUPPORT-PLAN-NOT-FOUND (err u504))

;; Data Variables
(define-data-var next-mother-id uint u1)
(define-data-var next-screening-id uint u1)
(define-data-var next-support-plan-id uint u1)

;; Data Maps
(define-map mothers
  { mother-id: uint }
  {
    name: (string-ascii 100),
    age: uint,
    delivery-date: uint,
    risk-factors: (string-ascii 200),
    contact-info: (string-ascii 100),
    provider-id: principal,
    status: (string-ascii 20),
    created-at: uint
  }
)

(define-map screening-records
  { screening-id: uint }
  {
    mother-id: uint,
    screening-date: uint,
    screening-type: (string-ascii 50), ;; "EPDS", "PHQ-9", "GAD-7"
    total-score: uint,
    risk-level: (string-ascii 20), ;; "low", "moderate", "high", "severe"
    screener-id: principal,
    notes: (string-ascii 300),
    follow-up-required: bool
  }
)

(define-map support-plans
  { support-plan-id: uint }
  {
    mother-id: uint,
    screening-id: uint,
    plan-date: uint,
    interventions: (string-ascii 400),
    referrals: (string-ascii 200),
    follow-up-schedule: (string-ascii 100),
    coordinator-id: principal,
    status: (string-ascii 20)
  }
)

(define-map follow-up-appointments
  { mother-id: uint, appointment-date: uint }
  {
    appointment-type: (string-ascii 50),
    provider-id: principal,
    status: (string-ascii 20),
    outcome: (string-ascii 200)
  }
)

(define-map authorized-providers
  { provider: principal }
  { authorized: bool }
)

;; Screening score thresholds
(define-map score-thresholds
  { screening-type: (string-ascii 50) }
  {
    low-threshold: uint,
    moderate-threshold: uint,
    high-threshold: uint
  }
)

;; Authorization Functions
(define-public (authorize-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set authorized-providers { provider: provider } { authorized: true }))
  )
)

(define-private (is-authorized-provider (provider principal))
  (default-to false (get authorized (map-get? authorized-providers { provider: provider })))
)

;; Initialize screening thresholds
(define-private (initialize-thresholds)
  (begin
    (map-set score-thresholds { screening-type: "EPDS" } { low-threshold: u9, moderate-threshold: u12, high-threshold: u19 })
    (map-set score-thresholds { screening-type: "PHQ-9" } { low-threshold: u4, moderate-threshold: u9, high-threshold: u14 })
    (map-set score-thresholds { screening-type: "GAD-7" } { low-threshold: u4, moderate-threshold: u9, high-threshold: u14 })
    (ok true)
  )
)

;; Mother Registration Functions
(define-public (register-mother
  (name (string-ascii 100))
  (age uint)
  (delivery-date uint)
  (risk-factors (string-ascii 200))
  (contact-info (string-ascii 100)))
  (let
    (
      (mother-id (var-get next-mother-id))
    )
    (begin
      (asserts! (is-authorized-provider tx-sender) ERR-NOT-AUTHORIZED)
      (asserts! (> (len name) u0) ERR-INVALID-INPUT)
      (asserts! (> age u0) ERR-INVALID-INPUT)
      (asserts! (<= delivery-date block-height) ERR-INVALID-INPUT)

      (map-set mothers
        { mother-id: mother-id }
        {
          name: name,
          age: age,
          delivery-date: delivery-date,
          risk-factors: risk-factors,
          contact-info: contact-info,
          provider-id: tx-sender,
          status: "active",
          created-at: block-height
        }
      )

      (var-set next-mother-id (+ mother-id u1))
      (ok mother-id)
    )
  )
)

;; Screening Functions
(define-public (conduct-screening
  (mother-id uint)
  (screening-type (string-ascii 50))
  (total-score uint)
  (notes (string-ascii 300)))
  (let
    (
      (screening-id (var-get next-screening-id))
      (risk-level (calculate-risk-level screening-type total-score))
    )
    (begin
      (asserts! (is-authorized-provider tx-sender) ERR-NOT-AUTHORIZED)
      (asserts! (is-some (map-get? mothers { mother-id: mother-id })) ERR-MOTHER-NOT-FOUND)
      (asserts! (> (len screening-type) u0) ERR-INVALID-INPUT)

      (map-set screening-records
        { screening-id: screening-id }
        {
          mother-id: mother-id,
          screening-date: block-height,
          screening-type: screening-type,
          total-score: total-score,
          risk-level: risk-level,
          screener-id: tx-sender,
          notes: notes,
          follow-up-required: (not (is-eq risk-level "low"))
        }
      )

      (var-set next-screening-id (+ screening-id u1))
      (ok screening-id)
    )
  )
)

(define-private (calculate-risk-level (screening-type (string-ascii 50)) (score uint))
  (let
    (
      (thresholds (map-get? score-thresholds { screening-type: screening-type }))
    )
    (if (is-some thresholds)
      (let
        (
          (low-thresh (get low-threshold (unwrap-panic thresholds)))
          (mod-thresh (get moderate-threshold (unwrap-panic thresholds)))
          (high-thresh (get high-threshold (unwrap-panic thresholds)))
        )
        (if (<= score low-thresh)
          "low"
          (if (<= score mod-thresh)
            "moderate"
            (if (<= score high-thresh)
              "high"
              "severe"
            )
          )
        )
      )
      "unknown"
    )
  )
)

;; Support Plan Functions
(define-public (create-support-plan
  (mother-id uint)
  (screening-id uint)
  (interventions (string-ascii 400))
  (referrals (string-ascii 200))
  (follow-up-schedule (string-ascii 100)))
  (let
    (
      (support-plan-id (var-get next-support-plan-id))
    )
    (begin
      (asserts! (is-authorized-provider tx-sender) ERR-NOT-AUTHORIZED)
      (asserts! (is-some (map-get? mothers { mother-id: mother-id })) ERR-MOTHER-NOT-FOUND)
      (asserts! (is-some (map-get? screening-records { screening-id: screening-id })) ERR-SCREENING-NOT-FOUND)

      (map-set support-plans
        { support-plan-id: support-plan-id }
        {
          mother-id: mother-id,
          screening-id: screening-id,
          plan-date: block-height,
          interventions: interventions,
          referrals: referrals,
          follow-up-schedule: follow-up-schedule,
          coordinator-id: tx-sender,
          status: "active"
        }
      )

      (var-set next-support-plan-id (+ support-plan-id u1))
      (ok support-plan-id)
    )
  )
)

(define-public (update-support-plan-status (support-plan-id uint) (status (string-ascii 20)))
  (let
    (
      (support-plan (map-get? support-plans { support-plan-id: support-plan-id }))
    )
    (begin
      (asserts! (is-some support-plan) ERR-SUPPORT-PLAN-NOT-FOUND)
      (asserts! (is-authorized-provider tx-sender) ERR-NOT-AUTHORIZED)

      (map-set support-plans
        { support-plan-id: support-plan-id }
        (merge (unwrap-panic support-plan) { status: status })
      )

      (ok true)
    )
  )
)

;; Follow-up Functions
(define-public (schedule-follow-up
  (mother-id uint)
  (appointment-date uint)
  (appointment-type (string-ascii 50)))
  (begin
    (asserts! (is-authorized-provider tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? mothers { mother-id: mother-id })) ERR-MOTHER-NOT-FOUND)
    (asserts! (> appointment-date block-height) ERR-INVALID-INPUT)

    (map-set follow-up-appointments
      { mother-id: mother-id, appointment-date: appointment-date }
      {
        appointment-type: appointment-type,
        provider-id: tx-sender,
        status: "scheduled",
        outcome: ""
      }
    )

    (ok true)
  )
)

(define-public (complete-follow-up
  (mother-id uint)
  (appointment-date uint)
  (outcome (string-ascii 200)))
  (let
    (
      (appointment (map-get? follow-up-appointments { mother-id: mother-id, appointment-date: appointment-date }))
    )
    (begin
      (asserts! (is-some appointment) ERR-INVALID-INPUT)
      (asserts! (is-authorized-provider tx-sender) ERR-NOT-AUTHORIZED)

      (map-set follow-up-appointments
        { mother-id: mother-id, appointment-date: appointment-date }
        (merge (unwrap-panic appointment) { status: "completed", outcome: outcome })
      )

      (ok true)
    )
  )
)

;; Read-only Functions
(define-read-only (get-mother (mother-id uint))
  (map-get? mothers { mother-id: mother-id })
)

(define-read-only (get-screening-record (screening-id uint))
  (map-get? screening-records { screening-id: screening-id })
)

(define-read-only (get-support-plan (support-plan-id uint))
  (map-get? support-plans { support-plan-id: support-plan-id })
)

(define-read-only (get-follow-up-appointment (mother-id uint) (appointment-date uint))
  (map-get? follow-up-appointments { mother-id: mother-id, appointment-date: appointment-date })
)

(define-read-only (get-next-mother-id)
  (var-get next-mother-id)
)

(define-read-only (get-next-screening-id)
  (var-get next-screening-id)
)
