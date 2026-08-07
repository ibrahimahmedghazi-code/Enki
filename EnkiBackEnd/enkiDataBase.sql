CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. users table
CREATE TABLE IF NOT EXISTS users (
    userid UUID PRIMARY KEY,
    fullname VARCHAR(50) NOT NULL,
    workat VARCHAR(255),
    age INT CHECK (age > 0),
    userdescription TEXT,
    speciality VARCHAR(100),
    profilepicturepath VARCHAR(500) DEFAULT 'assets/images/app_icon.png'
);

-- 2. courses table
CREATE TABLE IF NOT EXISTS courses (
    courseid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    imagepath VARCHAR(500) DEFAULT 'assets/images/app_icon.png',
    description TEXT,
    author VARCHAR(100),
    category VARCHAR(50),
    rating FLOAT DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    stage VARCHAR(500)
);

-- 3. modules table
CREATE TABLE IF NOT EXISTS modules (
    moduleid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    courseid UUID NOT NULL REFERENCES courses(courseid) ON DELETE CASCADE,
    numberofmodule INT
);

-- 4. lectures table
CREATE TABLE IF NOT EXISTS lectures (
    lectureid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    moduleid UUID NOT NULL REFERENCES modules(moduleid) ON DELETE CASCADE,
    lectureorder INT,
    lectureurl VARCHAR(500),
    title VARCHAR(255),
    durationminutes INT,
    isitvideo BOOLEAN
);

-- 5. userprogress table
CREATE TABLE IF NOT EXISTS userprogress (
    progressid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    userid UUID NOT NULL REFERENCES users(userid) ON DELETE CASCADE,
    courseid UUID NOT NULL REFERENCES courses(courseid) ON DELETE CASCADE,
    moduleid UUID NOT NULL REFERENCES modules(moduleid) ON DELETE CASCADE,
    lectureid UUID NOT NULL REFERENCES lectures(lectureid) ON DELETE CASCADE,
    isfinished BOOLEAN DEFAULT FALSE,
    CONSTRAINT unique_user_lecture UNIQUE(userid, lectureid)
);

-- 6. useractivate table
CREATE TABLE IF NOT EXISTS useractivate (
    activateid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    userid UUID NOT NULL REFERENCES users(userid) ON DELETE CASCADE,
    courseid UUID NOT NULL REFERENCES courses(courseid) ON DELETE CASCADE,
    enrolledat TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    lastwatchedat TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_course UNIQUE(userid, courseid)
);
