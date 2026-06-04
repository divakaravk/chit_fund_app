-- ============================================================
--  CHIT FUND SaaS — UPDATED MySQL SCHEMA
--  Multi-tenant: every table has company_id
-- ============================================================

CREATE DATABASE IF NOT EXISTS chit_fund_saas
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE chit_fund_saas;

-- ============================================================
-- 0. COMPANIES  ← புதுசா add பண்றோம்
-- ============================================================
CREATE TABLE companies (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    company_name    VARCHAR(150)    NOT NULL,
    company_code    VARCHAR(30)     UNIQUE NOT NULL,
    owner_name      VARCHAR(120)    NOT NULL,
    email           VARCHAR(120)    UNIQUE NOT NULL,
    phone           VARCHAR(15),
    address         JSON,
    plan            ENUM('trial','basic','pro','enterprise') NOT NULL DEFAULT 'trial',
    status          ENUM('active','suspended','cancelled')   NOT NULL DEFAULT 'active',
    trial_ends_at   DATE,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 1. USERS  ← company_id add பண்ணோம்
-- ============================================================
CREATE TABLE users (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    company_id      CHAR(36)        NOT NULL,                    -- ← NEW
    full_name       VARCHAR(120)    NOT NULL,
    phone_number    VARCHAR(15),
    address         JSON,
    role            ENUM('super_admin','admin','foreman','member') NOT NULL,
    status          ENUM('active','inactive')                    NOT NULL DEFAULT 'active',
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_phone_per_company (company_id, phone_number),  -- same phone, diff company OK
    CONSTRAINT fk_users_company FOREIGN KEY (company_id) REFERENCES companies(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 2. CHIT SCHEMES  ← company_id add பண்ணோம்
-- ============================================================
CREATE TABLE chit_schemes (
    id                      CHAR(36)        NOT NULL DEFAULT (UUID()),
    company_id              CHAR(36)        NOT NULL,            -- ← NEW
    scheme_name             VARCHAR(100)    NOT NULL,
    scheme_code             VARCHAR(20),
    chit_amount             DECIMAL(12,2)   NOT NULL,
    duration_months         INT             NOT NULL,
    total_members           INT             NOT NULL,
    monthly_contribution    DECIMAL(12,2)   NOT NULL,
    foreman_commission_pct  DECIMAL(5,2)    NOT NULL,
    bid_type                ENUM('open','sealed','lucky_draw')   NOT NULL,
    status                  ENUM('active','inactive','draft')    NOT NULL DEFAULT 'active',
    created_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_scheme_code_company (company_id, scheme_code), -- ← per company unique
    CONSTRAINT fk_schemes_company FOREIGN KEY (company_id) REFERENCES companies(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 3. CHIT GROUPS  ← company_id add பண்ணோம்
-- ============================================================
CREATE TABLE chit_groups (
    id                  CHAR(36)    NOT NULL DEFAULT (UUID()),
    company_id          CHAR(36)    NOT NULL,                    -- ← NEW
    scheme_id           CHAR(36)    NOT NULL,
    group_code          VARCHAR(20) NOT NULL,
    foreman_user_id     CHAR(36)    NOT NULL,
    status              ENUM('active','completed','paused','cancelled') NOT NULL DEFAULT 'active',
    current_month       INT         NOT NULL DEFAULT 1,
    next_auction_date   DATE,
    start_date          DATE        NOT NULL,
    created_at          DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_group_code_company (company_id, group_code),   -- ← per company unique
    CONSTRAINT fk_groups_company  FOREIGN KEY (company_id)       REFERENCES companies(id),
    CONSTRAINT fk_groups_scheme   FOREIGN KEY (scheme_id)        REFERENCES chit_schemes(id),
    CONSTRAINT fk_groups_foreman  FOREIGN KEY (foreman_user_id)  REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 4. MEMBERSHIPS  ← company_id add பண்ணோம்
-- ============================================================
CREATE TABLE memberships (
    id                      CHAR(36)      NOT NULL DEFAULT (UUID()),
    company_id              CHAR(36)      NOT NULL,              -- ← NEW
    chit_group_id           CHAR(36)      NOT NULL,
    user_id                 CHAR(36)      NOT NULL,
    ticket_number           INT           NOT NULL,
    status                  ENUM('active','inactive','defaulted') NOT NULL DEFAULT 'active',
    has_won_auction         TINYINT(1)    NOT NULL DEFAULT 0,
    won_auction_month       INT,
    total_paid              DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_due               DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_dividend_earned   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    joined_at               DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_group_ticket (chit_group_id, ticket_number),
    UNIQUE KEY uq_group_user   (chit_group_id, user_id),
    CONSTRAINT fk_mem_company FOREIGN KEY (company_id)    REFERENCES companies(id),
    CONSTRAINT fk_mem_group   FOREIGN KEY (chit_group_id) REFERENCES chit_groups(id),
    CONSTRAINT fk_mem_user    FOREIGN KEY (user_id)       REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 5. AUCTION CYCLES  ← company_id add பண்ணோம்
-- ============================================================
CREATE TABLE auction_cycles (
    id                      CHAR(36)      NOT NULL DEFAULT (UUID()),
    company_id              CHAR(36)      NOT NULL,              -- ← NEW
    chit_group_id           CHAR(36)      NOT NULL,
    cycle_month             INT           NOT NULL,
    auction_date            DATE          NOT NULL,
    status                  ENUM('scheduled','open','closed','cancelled') NOT NULL DEFAULT 'scheduled',
    prize_pool              DECIMAL(12,2) NOT NULL,
    foreman_commission      DECIMAL(12,2),
    winning_bid_amount      DECIMAL(12,2),
    dividend_per_member     DECIMAL(12,2),
    winner_membership_id    CHAR(36),
    is_lucky_draw           TINYINT(1)    NOT NULL DEFAULT 0,
    closed_at               DATETIME,
    PRIMARY KEY (id),
    UNIQUE KEY uq_group_month (chit_group_id, cycle_month),
    CONSTRAINT fk_ac_company FOREIGN KEY (company_id)           REFERENCES companies(id),
    CONSTRAINT fk_ac_group   FOREIGN KEY (chit_group_id)        REFERENCES chit_groups(id),
    CONSTRAINT fk_ac_winner  FOREIGN KEY (winner_membership_id) REFERENCES memberships(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 6. BIDS  ← company_id add பண்ணோம்
-- ============================================================
CREATE TABLE bids (
    id                  CHAR(36)      NOT NULL DEFAULT (UUID()),
    company_id          CHAR(36)      NOT NULL,                  -- ← NEW
    auction_cycle_id    CHAR(36)      NOT NULL,
    membership_id       CHAR(36)      NOT NULL,
    bid_amount          DECIMAL(12,2) NOT NULL,
    status              ENUM('submitted','won','lost','withdrawn') NOT NULL DEFAULT 'submitted',
    submitted_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_bid_per_member (auction_cycle_id, membership_id),
    CONSTRAINT fk_bids_company FOREIGN KEY (company_id)       REFERENCES companies(id),
    CONSTRAINT fk_bids_auction FOREIGN KEY (auction_cycle_id) REFERENCES auction_cycles(id),
    CONSTRAINT fk_bids_member  FOREIGN KEY (membership_id)    REFERENCES memberships(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 7. PAYMENTS  ← company_id add பண்ணோம்
-- ============================================================
CREATE TABLE payments (
    id                  CHAR(36)      NOT NULL DEFAULT (UUID()),
    company_id          CHAR(36)      NOT NULL,                  -- ← NEW
    membership_id       CHAR(36)      NOT NULL,
    auction_cycle_id    CHAR(36),
    payment_type        ENUM('monthly_contribution','settlement','penalty','refund') NOT NULL,
    amount              DECIMAL(12,2) NOT NULL,
    dividend_adjusted   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    net_payable         DECIMAL(12,2) NOT NULL,
    status              ENUM('pending','paid','overdue','waived') NOT NULL DEFAULT 'pending',
    payment_mode        ENUM('cash','upi','bank_transfer','cheque') NOT NULL,
    due_date            DATE          NOT NULL,
    paid_at             DATETIME,
    PRIMARY KEY (id),
    CONSTRAINT fk_pay_company FOREIGN KEY (company_id)       REFERENCES companies(id),
    CONSTRAINT fk_pay_member  FOREIGN KEY (membership_id)    REFERENCES memberships(id),
    CONSTRAINT fk_pay_auction FOREIGN KEY (auction_cycle_id) REFERENCES auction_cycles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 8. PRIZE DISBURSEMENTS  ← company_id add பண்ணோம்
-- ============================================================
CREATE TABLE prize_disbursements (
    id                  CHAR(36)      NOT NULL DEFAULT (UUID()),
    company_id          CHAR(36)      NOT NULL,                  -- ← NEW
    auction_cycle_id    CHAR(36)      NOT NULL UNIQUE,
    membership_id       CHAR(36)      NOT NULL,
    gross_amount        DECIMAL(12,2) NOT NULL,
    foreman_commission  DECIMAL(12,2) NOT NULL,
    bid_discount        DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    net_amount          DECIMAL(12,2) NOT NULL,
    status              ENUM('pending','processing','disbursed','failed') NOT NULL DEFAULT 'pending',
    utr_number          VARCHAR(22),
    disbursed_at        DATETIME,
    PRIMARY KEY (id),
    CONSTRAINT fk_disb_company FOREIGN KEY (company_id)       REFERENCES companies(id),
    CONSTRAINT fk_disb_auction FOREIGN KEY (auction_cycle_id) REFERENCES auction_cycles(id),
    CONSTRAINT fk_disb_member  FOREIGN KEY (membership_id)    REFERENCES memberships(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 9. SURETY BONDS  ← company_id add பண்ணோம்
-- ============================================================
CREATE TABLE surety_bonds (
    id                  CHAR(36)      NOT NULL DEFAULT (UUID()),
    company_id          CHAR(36)      NOT NULL,                  -- ← NEW
    membership_id       CHAR(36)      NOT NULL,
    guarantor_user_id   CHAR(36)      NOT NULL,
    bond_amount         DECIMAL(12,2) NOT NULL,
    status              ENUM('active','released','invoked')     NOT NULL DEFAULT 'active',
    valid_until         DATE          NOT NULL,
    created_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_sb_company   FOREIGN KEY (company_id)        REFERENCES companies(id),
    CONSTRAINT fk_sb_member    FOREIGN KEY (membership_id)     REFERENCES memberships(id),
    CONSTRAINT fk_sb_guarantor FOREIGN KEY (guarantor_user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 10. NOTIFICATIONS  ← company_id add பண்ணோம்
-- ============================================================
CREATE TABLE notifications (
    id          CHAR(36)     NOT NULL DEFAULT (UUID()),
    company_id  CHAR(36)     NOT NULL,                          -- ← NEW
    user_id     CHAR(36)     NOT NULL,
    type        ENUM('payment_due','auction_result','disbursement','general','kyc_update') NOT NULL,
    title       VARCHAR(120) NOT NULL,
    body        TEXT         NOT NULL,
    is_read     TINYINT(1)   NOT NULL DEFAULT 0,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_notif_company FOREIGN KEY (company_id) REFERENCES companies(id),
    CONSTRAINT fk_notif_user    FOREIGN KEY (user_id)    REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 11. AUDIT LOGS  ← company_id add பண்ணோம்
-- ============================================================
CREATE TABLE audit_logs (
    id              CHAR(36)     NOT NULL DEFAULT (UUID()),
    company_id      CHAR(36)     NOT NULL,                      -- ← NEW
    actor_user_id   CHAR(36),
    action          VARCHAR(80)  NOT NULL,
    entity_type     VARCHAR(50)  NOT NULL,
    entity_id       CHAR(36)     NOT NULL,
    old_value       JSON,
    new_value       JSON,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_audit_company FOREIGN KEY (company_id)   REFERENCES companies(id),
    CONSTRAINT fk_audit_actor   FOREIGN KEY (actor_user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- INDEXES
-- ============================================================
-- company_id indexes — மிக முக்கியம், இல்லன்னா slow queries
CREATE INDEX idx_users_company        ON users(company_id);
CREATE INDEX idx_schemes_company      ON chit_schemes(company_id);
CREATE INDEX idx_groups_company       ON chit_groups(company_id);
CREATE INDEX idx_memberships_company  ON memberships(company_id);
CREATE INDEX idx_auctions_company     ON auction_cycles(company_id);
CREATE INDEX idx_bids_company         ON bids(company_id);
CREATE INDEX idx_payments_company     ON payments(company_id);
CREATE INDEX idx_disbursements_company ON prize_disbursements(company_id);
CREATE INDEX idx_surety_company       ON surety_bonds(company_id);
CREATE INDEX idx_notif_company        ON notifications(company_id, user_id);
CREATE INDEX idx_audit_company        ON audit_logs(company_id, entity_type);
