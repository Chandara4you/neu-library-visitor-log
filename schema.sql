-- ============================================================
-- NEU LIBRARY VISITOR LOG SYSTEM — Database Schema
-- Run this entire script in your Supabase SQL Editor
-- Supabase Dashboard → SQL Editor → New Query → Paste → Run
-- ============================================================

-- 1. Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Users table (library visitors)
CREATE TABLE IF NOT EXISTS users (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  full_name       TEXT NOT NULL,
  email           TEXT UNIQUE NOT NULL,
  student_number  TEXT UNIQUE,
  user_type       TEXT CHECK (user_type IN ('Student','Faculty','Staff','Professor')),
  college         TEXT,
  password_hash   TEXT NOT NULL,
  qr_code         TEXT,
  is_blocked      BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Visits table
CREATE TABLE IF NOT EXISTS visits (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id         UUID REFERENCES users(id) ON DELETE CASCADE,
  full_name       TEXT,
  email           TEXT,
  student_number  TEXT,
  user_type       TEXT,
  college         TEXT,
  purpose         TEXT NOT NULL,
  time_in         TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  time_out        TIMESTAMP WITH TIME ZONE,
  date            DATE DEFAULT CURRENT_DATE,
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Admins table
CREATE TABLE IF NOT EXISTS admins (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name            TEXT NOT NULL,
  email           TEXT UNIQUE NOT NULL,
  password_hash   TEXT NOT NULL,
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Colleges table (reference)
CREATE TABLE IF NOT EXISTS colleges (
  id              SERIAL PRIMARY KEY,
  college_name    TEXT UNIQUE NOT NULL
);

-- 6. Seed colleges
INSERT INTO colleges (college_name) VALUES
  ('College of Informatics And Computing Studies'),
  ('College of Informatics and Computer Studies'),
  ('College of Arts and Sciences'),
  ('College of Business Administration'),
  ('College of Computer Studies'),
  ('College of Criminal Justice Education'),
  ('College of Education'),
  ('College of Engineering'),
  ('College of Nursing'),
  ('College of Tourism and Hospitality Management'),
  ('Graduate School'),
  ('Senior High School')
ON CONFLICT (college_name) DO NOTHING;

-- 7. Seed admins
--    Default credentials: admin@neu.edu.ph / Admin@NEU2024
--    password_hash for Google-login accounts = their email (they log in via Google, not password)
INSERT INTO admins (name, email, password_hash) VALUES
  ('Library Admin',          'admin@neu.edu.ph',             'Admin@NEU2024'),
  ('Prof. JC Esperanza',     'jcesperanza@neu.edu.ph',       'google-oauth'),
  ('Christian Adlawan',      'christian.adlawan@neu.edu.ph', 'google-oauth')
ON CONFLICT (email) DO NOTHING;

-- NOTE: Both christian.adlawan@neu.edu.ph and jcesperanza@neu.edu.ph have BOTH admin and visitor roles.
-- On Google login, the auth-callback.html page will detect both and show a role chooser.

-- 8. Row Level Security (RLS)
ALTER TABLE users   ENABLE ROW LEVEL SECURITY;
ALTER TABLE visits  ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins  ENABLE ROW LEVEL SECURITY;
ALTER TABLE colleges ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if re-running
DROP POLICY IF EXISTS "public_insert_users"   ON users;
DROP POLICY IF EXISTS "public_read_users"     ON users;
DROP POLICY IF EXISTS "public_update_users"   ON users;
DROP POLICY IF EXISTS "public_insert_visits"  ON visits;
DROP POLICY IF EXISTS "public_read_visits"    ON visits;
DROP POLICY IF EXISTS "public_update_visits"  ON visits;
DROP POLICY IF EXISTS "public_delete_visits"  ON visits;
DROP POLICY IF EXISTS "public_read_admins"    ON admins;
DROP POLICY IF EXISTS "public_read_colleges"  ON colleges;

-- Users policies
CREATE POLICY "public_insert_users"  ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "public_read_users"    ON users FOR SELECT USING (true);
CREATE POLICY "public_update_users"  ON users FOR UPDATE USING (true) WITH CHECK (true);

-- Visits policies
CREATE POLICY "public_insert_visits" ON visits FOR INSERT WITH CHECK (true);
CREATE POLICY "public_read_visits"   ON visits FOR SELECT USING (true);
CREATE POLICY "public_update_visits" ON visits FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "public_delete_visits" ON visits FOR DELETE USING (true);

-- Admins policies (read-only from client)
CREATE POLICY "public_read_admins"   ON admins FOR SELECT USING (true);

-- Colleges policies
CREATE POLICY "public_read_colleges" ON colleges FOR SELECT USING (true);

-- ============================================================
-- OPTIONAL: Create indexes for performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_visits_date    ON visits (date);
CREATE INDEX IF NOT EXISTS idx_visits_user_id ON visits (user_id);
CREATE INDEX IF NOT EXISTS idx_users_email    ON users  (email);
CREATE INDEX IF NOT EXISTS idx_users_sn       ON users  (student_number);
