--
-- PostgreSQL database dump
--

\restrict tpZswNX2bpBt3EgUVv227yYDd0OgZKleblH5vMOWCtXeR7lrWEEG4ymvghjwvzO

-- Dumped from database version 16.13 (Homebrew)
-- Dumped by pg_dump version 16.13 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: badge_tier; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.badge_tier AS ENUM (
    'bronze',
    'silver',
    'gold',
    'platinum'
);


--
-- Name: content_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.content_type AS ENUM (
    'article',
    'video',
    'podcast',
    'flashcard',
    'exercise',
    'journaling',
    'tutorial',
    'quiz',
    'book_summary',
    'book',
    'game',
    'music_playlist',
    'documentary'
);


--
-- Name: difficulty_level; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.difficulty_level AS ENUM (
    'beginner',
    'intermediate',
    'advanced'
);


--
-- Name: learning_goal; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.learning_goal AS ENUM (
    'learn',
    'focus',
    'relax',
    'productive',
    'create'
);


--
-- Name: session_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.session_status AS ENUM (
    'active',
    'completed',
    'abandoned'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: achievements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.achievements (
    id integer NOT NULL,
    slug character varying(80) NOT NULL,
    title character varying(120) NOT NULL,
    description text,
    icon_name character varying(50),
    tier public.badge_tier DEFAULT 'bronze'::public.badge_tier NOT NULL,
    xp_bonus smallint DEFAULT 0 NOT NULL,
    trigger_type character varying(50) NOT NULL,
    trigger_value integer NOT NULL
);


--
-- Name: achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.achievements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.achievements_id_seq OWNED BY public.achievements.id;


--
-- Name: authors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authors (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    bio text,
    website character varying(255),
    avatar_url character varying(255)
);


--
-- Name: authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.authors_id_seq OWNED BY public.authors.id;


--
-- Name: bookmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookmarks (
    id integer NOT NULL,
    user_id integer NOT NULL,
    content_id integer NOT NULL,
    note text,
    saved_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: bookmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookmarks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookmarks_id_seq OWNED BY public.bookmarks.id;


--
-- Name: content_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_topics (
    id integer NOT NULL,
    content_id integer NOT NULL,
    topic_id integer NOT NULL
);


--
-- Name: content_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_topics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_topics_id_seq OWNED BY public.content_topics.id;


--
-- Name: contents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contents (
    id integer NOT NULL,
    author_id integer,
    title character varying(255) NOT NULL,
    description text,
    content_type public.content_type NOT NULL,
    difficulty public.difficulty_level DEFAULT 'beginner'::public.difficulty_level NOT NULL,
    duration_minutes smallint NOT NULL,
    url character varying(500),
    thumbnail_url character varying(500),
    preview_video_url character varying(500),
    is_offline_available boolean DEFAULT false NOT NULL,
    language character varying(10) DEFAULT 'en'::character varying NOT NULL,
    view_count integer DEFAULT 0 NOT NULL,
    avg_rating numeric(3,2),
    xp_reward smallint DEFAULT 10 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_published boolean DEFAULT true NOT NULL,
    ebook_url character varying(500),
    embedded_html text,
    playlist_url character varying(500),
    page_count smallint,
    CONSTRAINT contents_avg_rating_check CHECK (((avg_rating >= (0)::numeric) AND (avg_rating <= (5)::numeric))),
    CONSTRAINT contents_duration_minutes_check CHECK (((duration_minutes >= 1) AND (duration_minutes <= 720)))
);


--
-- Name: contents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contents_id_seq OWNED BY public.contents.id;


--
-- Name: onboarding_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.onboarding_questions (
    id integer NOT NULL,
    question_text character varying(255) NOT NULL,
    answer_type character varying(20) DEFAULT 'multi_select'::character varying NOT NULL,
    display_order smallint DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: onboarding_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.onboarding_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: onboarding_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.onboarding_questions_id_seq OWNED BY public.onboarding_questions.id;


--
-- Name: progress; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.progress (
    id integer NOT NULL,
    user_id integer NOT NULL,
    content_id integer NOT NULL,
    completion_percentage smallint DEFAULT 0 NOT NULL,
    is_completed boolean DEFAULT false NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT progress_completion_percentage_check CHECK (((completion_percentage >= 0) AND (completion_percentage <= 100)))
);


--
-- Name: progress_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.progress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.progress_id_seq OWNED BY public.progress.id;


--
-- Name: recommendations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recommendations (
    id integer NOT NULL,
    session_id integer NOT NULL,
    content_id integer NOT NULL,
    score numeric(5,2) NOT NULL,
    rank smallint NOT NULL,
    was_opened boolean DEFAULT false NOT NULL,
    reason_template character varying(50),
    reason_text text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT recommendations_score_check CHECK (((score >= (0)::numeric) AND (score <= (100)::numeric)))
);


--
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recommendations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recommendations_id_seq OWNED BY public.recommendations.id;


--
-- Name: time_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.time_sessions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    available_minutes smallint NOT NULL,
    selected_goal public.learning_goal,
    selected_difficulty public.difficulty_level,
    selected_topic_id integer,
    status public.session_status DEFAULT 'active'::public.session_status NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone,
    is_offline boolean DEFAULT false NOT NULL,
    xp_earned smallint DEFAULT 0 NOT NULL,
    CONSTRAINT time_sessions_available_minutes_check CHECK (((available_minutes >= 1) AND (available_minutes <= 720)))
);


--
-- Name: time_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.time_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: time_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.time_sessions_id_seq OWNED BY public.time_sessions.id;


--
-- Name: topic_subtags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.topic_subtags (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    label character varying(80) NOT NULL,
    slug character varying(80) NOT NULL,
    display_order smallint DEFAULT 0 NOT NULL
);


--
-- Name: topic_subtags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.topic_subtags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topic_subtags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.topic_subtags_id_seq OWNED BY public.topic_subtags.id;


--
-- Name: topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.topics (
    id integer NOT NULL,
    name character varying(80) NOT NULL,
    slug character varying(80) NOT NULL,
    description text,
    icon_name character varying(50),
    color_hex character varying(7)
);


--
-- Name: topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.topics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.topics_id_seq OWNED BY public.topics.id;


--
-- Name: user_achievements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_achievements (
    id integer NOT NULL,
    user_id integer NOT NULL,
    achievement_id integer NOT NULL,
    earned_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_achievements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_achievements_id_seq OWNED BY public.user_achievements.id;


--
-- Name: user_onboarding_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_onboarding_answers (
    id integer NOT NULL,
    user_id integer NOT NULL,
    question_id integer NOT NULL,
    answer_value text NOT NULL,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_onboarding_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_onboarding_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_onboarding_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_onboarding_answers_id_seq OWNED BY public.user_onboarding_answers.id;


--
-- Name: user_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_preferences (
    id integer NOT NULL,
    user_id integer NOT NULL,
    default_goal public.learning_goal DEFAULT 'learn'::public.learning_goal NOT NULL,
    default_difficulty public.difficulty_level DEFAULT 'beginner'::public.difficulty_level NOT NULL,
    prefer_offline boolean DEFAULT false NOT NULL,
    preferred_language character varying(10) DEFAULT 'en'::character varying NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_preferences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_preferences_id_seq OWNED BY public.user_preferences.id;


--
-- Name: user_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_stats (
    id integer NOT NULL,
    user_id integer NOT NULL,
    total_xp integer DEFAULT 0 NOT NULL,
    current_level smallint DEFAULT 1 NOT NULL,
    current_streak_days smallint DEFAULT 0 NOT NULL,
    longest_streak_days smallint DEFAULT 0 NOT NULL,
    last_active_date date,
    total_sessions integer DEFAULT 0 NOT NULL,
    total_minutes_spent integer DEFAULT 0 NOT NULL,
    total_contents_completed integer DEFAULT 0 NOT NULL,
    favorite_topic_id integer,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_stats_id_seq OWNED BY public.user_stats.id;


--
-- Name: user_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_topics (
    id integer NOT NULL,
    user_id integer NOT NULL,
    topic_id integer NOT NULL,
    weight smallint DEFAULT 5 NOT NULL,
    source character varying(20) DEFAULT 'onboarding'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_topics_weight_check CHECK (((weight >= 1) AND (weight <= 10)))
);


--
-- Name: user_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_topics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_topics_id_seq OWNED BY public.user_topics.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(255) NOT NULL,
    display_name character varying(100),
    avatar_url character varying(255),
    onboarding_completed boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vw_content_popularity; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_content_popularity AS
SELECT
    NULL::integer AS id,
    NULL::character varying(255) AS title,
    NULL::public.content_type AS content_type,
    NULL::public.difficulty_level AS difficulty,
    NULL::smallint AS duration_minutes,
    NULL::numeric(3,2) AS avg_rating,
    NULL::integer AS view_count,
    NULL::smallint AS xp_reward,
    NULL::boolean AS has_preview,
    NULL::bigint AS times_recommended,
    NULL::bigint AS completions;


--
-- Name: vw_user_dashboard; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_user_dashboard AS
 SELECT u.id AS user_id,
    u.username,
    s.total_xp,
    s.current_level,
    s.current_streak_days,
    s.total_sessions,
    s.total_minutes_spent,
    s.total_contents_completed,
    count(DISTINCT b.content_id) AS bookmarked_contents,
    round(((100.0 * (s.total_contents_completed)::numeric) / (NULLIF(count(DISTINCT p.content_id), 0))::numeric), 1) AS completion_rate_pct
   FROM (((public.users u
     JOIN public.user_stats s ON ((s.user_id = u.id)))
     LEFT JOIN public.progress p ON ((p.user_id = u.id)))
     LEFT JOIN public.bookmarks b ON ((b.user_id = u.id)))
  GROUP BY u.id, u.username, s.total_xp, s.current_level, s.current_streak_days, s.total_sessions, s.total_minutes_spent, s.total_contents_completed;


--
-- Name: vw_user_profile_card; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_user_profile_card AS
 SELECT u.id,
    u.username,
    u.display_name,
    s.total_xp,
    s.current_level,
    s.current_streak_days,
    s.longest_streak_days,
    s.total_sessions,
    s.total_minutes_spent,
    s.total_contents_completed,
    t.name AS favorite_topic,
    t.color_hex AS favorite_topic_color,
    count(ua.id) AS total_badges
   FROM (((public.users u
     JOIN public.user_stats s ON ((s.user_id = u.id)))
     LEFT JOIN public.topics t ON ((t.id = s.favorite_topic_id)))
     LEFT JOIN public.user_achievements ua ON ((ua.user_id = u.id)))
  GROUP BY u.id, u.username, u.display_name, s.total_xp, s.current_level, s.current_streak_days, s.longest_streak_days, s.total_sessions, s.total_minutes_spent, s.total_contents_completed, t.name, t.color_hex;


--
-- Name: achievements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievements ALTER COLUMN id SET DEFAULT nextval('public.achievements_id_seq'::regclass);


--
-- Name: authors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authors ALTER COLUMN id SET DEFAULT nextval('public.authors_id_seq'::regclass);


--
-- Name: bookmarks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks ALTER COLUMN id SET DEFAULT nextval('public.bookmarks_id_seq'::regclass);


--
-- Name: content_topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_topics ALTER COLUMN id SET DEFAULT nextval('public.content_topics_id_seq'::regclass);


--
-- Name: contents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contents ALTER COLUMN id SET DEFAULT nextval('public.contents_id_seq'::regclass);


--
-- Name: onboarding_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onboarding_questions ALTER COLUMN id SET DEFAULT nextval('public.onboarding_questions_id_seq'::regclass);


--
-- Name: progress id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress ALTER COLUMN id SET DEFAULT nextval('public.progress_id_seq'::regclass);


--
-- Name: recommendations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations ALTER COLUMN id SET DEFAULT nextval('public.recommendations_id_seq'::regclass);


--
-- Name: time_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_sessions ALTER COLUMN id SET DEFAULT nextval('public.time_sessions_id_seq'::regclass);


--
-- Name: topic_subtags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_subtags ALTER COLUMN id SET DEFAULT nextval('public.topic_subtags_id_seq'::regclass);


--
-- Name: topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topics ALTER COLUMN id SET DEFAULT nextval('public.topics_id_seq'::regclass);


--
-- Name: user_achievements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_achievements ALTER COLUMN id SET DEFAULT nextval('public.user_achievements_id_seq'::regclass);


--
-- Name: user_onboarding_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_onboarding_answers ALTER COLUMN id SET DEFAULT nextval('public.user_onboarding_answers_id_seq'::regclass);


--
-- Name: user_preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences ALTER COLUMN id SET DEFAULT nextval('public.user_preferences_id_seq'::regclass);


--
-- Name: user_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_stats ALTER COLUMN id SET DEFAULT nextval('public.user_stats_id_seq'::regclass);


--
-- Name: user_topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_topics ALTER COLUMN id SET DEFAULT nextval('public.user_topics_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: achievements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.achievements (id, slug, title, description, icon_name, tier, xp_bonus, trigger_type, trigger_value) FROM stdin;
1	first_spark	First Spark	Completed your very first session.	flame	bronze	25	total_sessions	1
2	on_a_roll	On a Roll	3-day activity streak.	flame	bronze	50	streak_days	3
3	week_warrior	Week Warrior	7-day streak — a full week of TimeWise.	shield	silver	100	streak_days	7
4	unstoppable	Unstoppable	30-day streak. Seriously impressive.	trophy	gold	300	streak_days	30
5	level_up	Level Up	Reached Level 5.	star	bronze	50	current_level	5
6	xp_500	500 XP Club	Earned 500 total XP.	zap	silver	75	total_xp	500
7	xp_2000	XP Powerhouse	Earned 2000 total XP.	zap	gold	200	total_xp	2000
8	first_hour	First Hour	Spent a total of 60 minutes learning.	clock	bronze	30	total_minutes_spent	60
9	ten_hours	Time Investor	Spent 10 total hours in TimeWise.	clock	silver	100	total_minutes_spent	600
10	completer_5	Finisher	Completed 5 pieces of content.	check-circle	bronze	50	total_contents_completed	5
11	completer_25	Avid Learner	Completed 25 pieces of content.	check-circle	silver	150	total_contents_completed	25
12	completer_100	Century Club	Completed 100 pieces of content.	check-circle	gold	500	total_contents_completed	100
13	topic_explorer	Topic Explorer	Completed content in 5 different topics.	compass	silver	100	topics_explored	5
14	night_owl	Night Owl	Completed a session after 10 PM.	moon	bronze	25	late_session	22
15	speed_runner	Speed Runner	Completed a 5-minute session 10 times.	bolt	bronze	50	short_session_count	10
16	bookworm	Bookworm	Completed 5 book summaries.	book	silver	100	book_summary_completions	5
\.


--
-- Data for Name: authors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.authors (id, name, bio, website, avatar_url) FROM stdin;
1	Alex Carter	Software educator and tech writer. Makes complex concepts approachable.	https://alexcarter.dev	https://cdn.timewise.app/avatars/alex.jpg
2	Emily Rhodes	Polyglot and language coach. Has learned 5 languages and teaches the process.	https://emilyrhodes.com	https://cdn.timewise.app/avatars/emily.jpg
3	Marcus Webb	Productivity coach specializing in GTD, deep work and habit systems.	https://marcuswebb.io	https://cdn.timewise.app/avatars/marcus.jpg
4	Claire Bennett	Artist, illustrator and craft educator. Runs weekend creative workshops.	https://clairebennett.art	https://cdn.timewise.app/avatars/claire.jpg
5	Daniel Torres	Sports scientist and certified nutritionist. Evidence-based wellness writer.	https://danieltorres.net	https://cdn.timewise.app/avatars/daniel.jpg
6	Sofia Reyes	Music teacher and guitarist. Specializes in beginner-friendly instrument guides.	https://sofiareyes.music	https://cdn.timewise.app/avatars/sofia.jpg
7	Nathan Cole	Personal finance advisor and CFA candidate.	https://nathancole.com	https://cdn.timewise.app/avatars/nathan.jpg
8	Laura Simmons	Clinical psychologist and mindfulness trainer. Researcher in cognitive science.	https://laurasimmons.psy	https://cdn.timewise.app/avatars/laura.jpg
9	Olivia Grant	Philosophy PhD and podcast host. Makes stoicism and existentialism click.	https://oliviagrant.com	https://cdn.timewise.app/avatars/olivia.jpg
10	James Park	History teacher and trivia enthusiast. Writes about culture and forgotten stories.	https://jamespark.history	https://cdn.timewise.app/avatars/james.jpg
\.


--
-- Data for Name: bookmarks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bookmarks (id, user_id, content_id, note, saved_at) FROM stdin;
1	1	2	Great for getting more out of AI tools daily	2026-03-21 00:46:13.139967+03
2	1	4	\N	2026-03-21 00:46:13.139967+03
3	1	12	Re-read before next planning session	2026-03-21 00:46:13.139967+03
4	1	44	Atomic Habits — gift to future self	2026-03-21 00:46:13.139967+03
5	2	6	Foundational — revisit every few months	2026-03-21 00:46:13.139967+03
6	2	8	\N	2026-03-21 00:46:13.139967+03
7	2	35	Cognitive distortions list for tough weeks	2026-03-21 00:46:13.139967+03
8	2	45	Thinking Fast and Slow — top priority read	2026-03-21 00:46:13.139967+03
9	3	12	Core reference for my work system	2026-03-21 00:46:13.139967+03
10	3	13	\N	2026-03-21 00:46:13.139967+03
11	3	42	Lean startup for side project	2026-03-21 00:46:13.139967+03
12	3	44	Atomic Habits — habit tracker idea	2026-03-21 00:46:13.139967+03
13	4	20	Watercolor — buy supplies first	2026-03-21 00:46:13.139967+03
14	4	24	Learn these 3 chords this month	2026-03-21 00:46:13.139967+03
15	4	19	Sketch-a-day challenge starting Monday	2026-03-21 00:46:13.139967+03
16	5	40	Show this compound interest chart to friends	2026-03-21 00:46:13.139967+03
17	5	41	Monthly budget reference	2026-03-21 00:46:13.139967+03
18	5	46	Psychology of Money — must read	2026-03-21 00:46:13.139967+03
19	6	37	Morning box breathing non-negotiable	2026-03-21 00:46:13.139967+03
20	6	38	\N	2026-03-21 00:46:13.139967+03
21	6	35	Cognitive distortions — good reference	2026-03-21 00:46:13.139967+03
22	7	28	Best Roman history overview I found	2026-03-21 00:46:13.139967+03
23	7	31	Scientific revolution — want to go deeper	2026-03-21 00:46:13.139967+03
24	7	47	Meditations — offline read	2026-03-21 00:46:13.139967+03
25	8	24	Guitar chord chart to print out	2026-03-21 00:46:13.139967+03
26	8	23	Sheet music basics — review weekly	2026-03-21 00:46:13.139967+03
27	8	26	Music theory deep dive next	2026-03-21 00:46:13.139967+03
28	10	135	\N	2026-03-21 07:06:38.966036+03
32	10	178	\N	2026-03-21 09:00:05.754308+03
36	10	125	\N	2026-03-21 12:09:40.819665+03
\.


--
-- Data for Name: content_topics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.content_topics (id, content_id, topic_id) FROM stdin;
1	1	1
2	2	1
3	2	3
4	3	1
5	4	1
6	5	1
7	6	2
8	7	2
9	7	3
10	8	2
11	9	2
12	10	2
13	10	3
14	11	3
15	12	3
16	13	3
17	14	3
18	14	9
19	15	4
20	15	11
21	16	4
22	17	4
23	18	5
24	19	5
25	20	5
26	21	5
27	22	5
28	22	9
29	23	6
30	24	6
31	25	6
32	26	6
33	27	6
34	28	7
35	29	7
36	30	7
37	31	7
38	31	8
39	32	7
40	33	8
41	33	9
42	34	8
43	35	9
44	35	11
45	36	9
46	36	3
47	37	11
48	37	4
49	38	11
50	38	4
51	39	11
52	39	9
53	40	10
54	41	10
55	42	12
56	42	3
57	43	12
58	43	10
59	44	3
60	44	9
61	45	9
62	45	8
63	46	10
64	46	9
65	47	8
66	47	11
67	82	8
68	82	11
69	83	7
70	83	8
71	84	7
72	85	8
73	86	8
74	86	9
75	87	3
76	87	8
77	88	8
78	88	12
79	89	9
80	90	10
81	90	12
82	91	7
83	92	9
84	92	3
85	93	9
86	93	3
87	94	9
88	95	9
89	95	3
90	96	9
91	97	9
92	98	2
93	98	7
94	99	1
95	99	3
96	100	5
97	101	9
98	101	3
99	102	11
100	102	3
101	103	11
102	103	3
103	104	6
104	104	11
105	105	6
106	105	11
107	106	11
108	106	4
109	107	11
110	107	9
111	108	6
112	108	3
113	109	6
114	110	11
115	110	4
116	111	11
117	111	3
118	112	1
119	112	9
120	113	5
121	113	8
122	114	12
123	114	1
124	115	7
125	116	9
126	116	7
127	117	1
128	117	9
129	118	4
130	118	8
131	119	3
132	119	8
133	120	4
134	120	7
135	121	5
136	121	12
137	122	7
138	122	8
139	123	7
140	124	7
141	125	7
142	125	10
143	126	7
144	127	7
145	127	4
146	128	7
147	128	1
148	129	7
149	129	12
150	130	7
151	130	8
152	131	7
153	131	8
154	132	7
155	132	5
156	133	7
157	134	7
158	134	9
159	135	7
160	136	7
161	136	8
162	137	7
163	137	9
164	138	7
165	139	7
166	140	7
167	140	8
168	141	7
169	141	8
170	142	5
171	142	7
172	143	5
173	143	7
174	144	5
175	144	7
176	145	5
177	145	7
178	146	6
179	146	7
180	147	7
181	147	8
182	148	7
183	148	9
184	149	5
185	149	7
186	150	7
187	150	5
188	151	7
189	151	2
190	152	7
191	152	1
192	153	5
193	153	7
194	154	6
195	154	8
196	155	5
197	155	7
198	156	7
199	156	8
200	157	1
201	158	1
202	158	3
203	159	1
204	160	1
205	161	1
206	161	7
207	162	1
208	163	1
209	164	1
210	165	1
211	165	3
212	166	1
213	167	1
214	167	9
215	168	1
216	169	1
217	170	1
218	171	1
219	171	3
220	172	7
221	172	8
222	173	7
223	173	4
224	174	1
225	174	4
226	175	7
227	175	4
228	176	7
229	177	9
230	177	4
231	178	7
232	179	7
233	179	1
234	180	4
235	181	7
236	181	1
237	48	1
238	48	3
239	49	1
240	50	1
241	51	2
242	52	2
243	53	2
244	54	3
245	54	9
246	55	3
247	56	3
248	56	9
249	57	4
250	58	4
251	59	4
252	60	5
253	61	5
254	62	5
255	63	6
256	64	6
257	64	1
258	65	6
259	66	7
260	67	7
261	67	10
262	68	7
263	69	8
264	70	8
265	70	9
266	71	9
267	71	3
268	72	9
269	73	9
270	73	3
271	74	10
272	75	10
273	76	10
274	77	11
275	77	9
276	78	11
277	79	12
278	79	3
279	80	12
280	80	3
281	81	12
282	81	10
\.


--
-- Data for Name: contents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.contents (id, author_id, title, description, content_type, difficulty, duration_minutes, url, thumbnail_url, preview_video_url, is_offline_available, language, view_count, avg_rating, xp_reward, created_at, is_published, ebook_url, embedded_html, playlist_url, page_count) FROM stdin;
1	1	How the Internet Actually Works	DNS, HTTP, TCP/IP and servers explained without any code.	article	beginner	8	https://www.youtube.com/watch?v=x3c1ih2NJEg	https://cdn.timewise.app/thumbs/internet.jpg	https://cdn.timewise.app/previews/how-internet-works.mp4	t	en	21400	4.70	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
2	1	Prompt Engineering: Getting More Out of AI Tools	Zero-shot, few-shot and chain-of-thought techniques for ChatGPT and Claude.	article	beginner	10	https://www.promptingguide.ai/	https://cdn.timewise.app/thumbs/prompt.jpg	https://cdn.timewise.app/previews/prompt-engineering.mp4	t	en	18700	4.60	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
3	1	Git in Plain English: Version Control for Everyone	Commits, branches and pull requests — no jargon, just the mental model.	video	beginner	15	https://www.youtube.com/watch?v=hwP7WQkmECE	https://cdn.timewise.app/thumbs/git.jpg	\N	f	en	14200	4.50	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
4	1	What Is Machine Learning? A Visual Intro	Training, features and predictions explained with everyday examples.	article	beginner	12	https://www.youtube.com/watch?v=ukzFI9rgwfU	https://cdn.timewise.app/thumbs/ml.jpg	\N	t	en	11300	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
5	1	Build Something with No Code: Intro to No-Code Tools	Overview of Bubble, Webflow and Glide — build without writing a single line.	video	intermediate	20	https://www.youtube.com/watch?v=zdfGFBWbzHw	https://cdn.timewise.app/thumbs/nocode.jpg	\N	f	en	9100	4.40	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
6	2	How to Learn Any Language: The Core Method	Comprehensible input, spaced repetition and speaking early.	article	beginner	10	https://www.youtube.com/watch?v=_IOZbJ7PCPk	https://cdn.timewise.app/thumbs/language-method.jpg	https://cdn.timewise.app/previews/how-to-learn-any-language.mp4	t	en	24600	4.90	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
7	2	Spaced Repetition: Never Forget a Word Again	How Anki and the forgetting curve work — and how to set up your first deck.	article	beginner	8	https://www.youtube.com/watch?v=eVajQPuRmk8	https://cdn.timewise.app/thumbs/anki.jpg	\N	t	en	19800	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
8	2	Small Talk Phrases That Work in Any Language	Universal conversation starters and how to adapt them for any target language.	flashcard	beginner	10	https://www.youtube.com/watch?v=0XRL3T8f8bA	https://cdn.timewise.app/thumbs/smalltalk.jpg	\N	t	en	16300	4.70	10	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
9	2	The Shadowing Technique: Sound Like a Native Faster	Step-by-step guide to the most effective pronunciation and fluency drill.	video	intermediate	15	https://www.youtube.com/watch?v=VyPtHCNy7e4	https://cdn.timewise.app/thumbs/shadowing.jpg	\N	f	en	12700	4.60	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
10	2	Language Learning Journal: 5 Minutes a Day	Daily writing prompts to build output habit in your target language.	journaling	beginner	5	\N	\N	\N	t	en	8900	4.50	10	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
11	3	Does the Pomodoro Technique Actually Work?	Neuroscience behind focus cycles and why breaks are not optional.	article	beginner	7	https://medium.com/@language_learning/5-minute-journaling-for-language-learners-a-practical-guide-3c8d7e1a2f45	https://cdn.timewise.app/thumbs/pomodoro.jpg	https://cdn.timewise.app/previews/pomodoro-analysis.mp4	t	en	31000	4.60	10	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
12	3	Deep Work by Cal Newport: Core Ideas	Attention depth, shallow work traps and ritual design.	article	intermediate	10	https://www.youtube.com/watch?v=mNBmG24djoY	https://cdn.timewise.app/thumbs/deepwork.jpg	https://cdn.timewise.app/previews/deep-work-summary.mp4	t	en	19800	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
13	3	Getting Things Done (GTD) in 15 Minutes	Capture, Clarify, Organize, Reflect, Engage — the whole system.	video	beginner	15	https://www.youtube.com/watch?v=gTaJhjQHcf8	https://cdn.timewise.app/thumbs/gtd.jpg	\N	f	en	14500	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
14	3	Weekly Planning Journal: 6 Questions Every Sunday	Review the past week and design the next one intentionally.	journaling	beginner	10	\N	\N	\N	t	en	8700	4.50	10	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
15	5	Desk Exercises: Get Active in 7 Minutes	8 equipment-free movements at your workstation.	exercise	beginner	7	https://www.youtube.com/watch?v=gCswMsONkwY	https://cdn.timewise.app/thumbs/desk-exercise.jpg	\N	t	en	26700	4.80	10	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
16	5	Sleep Hygiene: 10 Science-Backed Rules	Circadian rhythm, blue light and temperature — what the research says.	article	beginner	10	https://medium.com/@productivitylab/weekly-review-6-questions-every-sunday-9f1c3b2e4d67	https://cdn.timewise.app/thumbs/sleep.jpg	\N	t	en	19400	4.70	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
17	5	The 80/20 of Getting Healthier Without Obsessing	The handful of habits that account for most health outcomes.	article	intermediate	12	https://www.youtube.com/watch?v=tFrAi04MUt0	https://cdn.timewise.app/thumbs/health.jpg	\N	t	en	13800	4.50	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
18	4	Beginner Drawing: How to See Like an Artist	The shift from drawing what you think you see to what is actually there.	article	beginner	10	https://www.youtube.com/watch?v=t0kACis_dJE	https://cdn.timewise.app/thumbs/drawing.jpg	\N	t	en	17200	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
19	4	The One-Sketch-a-Day Habit: How to Start and Stick With It	Tiny creative practice, no talent required — just a pen and 5 minutes.	article	beginner	7	https://medium.com/@dr_attia/the-8020-rule-of-health-2a5f1c3e9b84	https://cdn.timewise.app/thumbs/sketch.jpg	\N	t	en	13400	4.70	10	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
20	4	Watercolor for Complete Beginners: First Wash Techniques	Flat wash, graded wash and wet-on-wet — your first 20 minutes with watercolor.	video	beginner	20	https://www.youtube.com/watch?v=PbS9MxMvPXE	https://cdn.timewise.app/thumbs/watercolor.jpg	\N	f	en	11600	4.90	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
21	4	Linocut Printmaking: A Beginner Project Start to Finish	From carving to inking to printing — a satisfying craft you can do at home.	video	intermediate	25	https://medium.com/@sketchdaily/the-one-sketch-a-day-habit-4e8c3b7d2a91	https://cdn.timewise.app/thumbs/linocut.jpg	\N	f	en	7300	4.60	30	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
22	4	Creative Journal Prompts: Visual + Written Combos	Mixed-media journaling prompts combining doodles with reflection.	journaling	beginner	10	\N	\N	\N	t	en	9800	4.70	10	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
23	6	How to Read Sheet Music: The Absolute Basics	Notes, rhythm, time signatures — everything for your first piece.	article	beginner	12	https://www.youtube.com/watch?v=zi1MkHzLbIE	https://cdn.timewise.app/thumbs/sheet-music.jpg	\N	t	en	22100	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
24	6	Guitar for Beginners: Your First 3 Chords	G, C and Em — three chords that unlock dozens of songs.	video	beginner	15	https://www.youtube.com/watch?v=UDCKQxMfmHQ	https://cdn.timewise.app/thumbs/guitar.jpg	https://cdn.timewise.app/previews/guitar-first-3-chords.mp4	f	en	31400	4.90	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
25	6	Ear Training 101: Recognizing Intervals	Train your ear to identify musical intervals — the foundation of playing by ear.	exercise	beginner	10	https://medium.com/@artjournal/creative-journal-prompts-visual-and-written-combos-5d2a7b8f3c16	https://cdn.timewise.app/thumbs/ear-training.jpg	\N	t	en	14800	4.70	10	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
26	6	Music Theory: Why Chords Sound Good Together	Keys, scales and harmony explained without complex notation.	article	intermediate	15	https://www.youtube.com/watch?v=ZN9ECe9tLK8	https://cdn.timewise.app/thumbs/music-theory.jpg	\N	t	en	12200	4.60	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
27	6	Daily Ear Training Drill: 5 Minutes	A short daily exercise to build musical ear — works with any instrument.	exercise	beginner	5	\N	\N	\N	t	en	9600	4.80	10	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
28	10	Why the Roman Empire Fell: 5 Competing Theories	Military, economic and cultural explanations — what historians agree on.	article	beginner	10	https://www.youtube.com/watch?v=GyF1OhpHIMk	https://cdn.timewise.app/thumbs/rome.jpg	https://cdn.timewise.app/previews/roman-empire-fall.mp4	t	en	28700	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
29	10	The Cold War in 10 Minutes	Yalta to the Berlin Wall to the Cuban Missile Crisis — key turning points.	article	beginner	10	https://www.youtube.com/watch?v=_UxnDGGexes	https://cdn.timewise.app/thumbs/coldwar.jpg	\N	t	en	19300	4.70	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
30	10	How Maps Shaped the World: A Brief History of Cartography	The politics of mapping — borders, projections and missing places.	podcast	beginner	15	https://www.youtube.com/watch?v=rgaTLrZGlk0	https://cdn.timewise.app/thumbs/maps.jpg	\N	f	en	13400	4.60	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
31	10	The Scientific Revolution: How Modern Science Was Born	Copernicus to Newton — the ideas that changed how we see the world.	article	intermediate	12	https://www.youtube.com/watch?v=HqMHG_XGxiU	https://cdn.timewise.app/thumbs/science-history.jpg	\N	t	en	10800	4.70	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
32	10	Daily Trivia Challenge: 5-Minute General Knowledge Quiz	Rotating 10 questions covering history, science, geography and culture.	quiz	beginner	5	https://www.youtube.com/watch?v=Eqqn3dCIPuA	https://cdn.timewise.app/thumbs/trivia.jpg	https://cdn.timewise.app/previews/daily-trivia.mp4	f	en	34200	4.90	10	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
33	9	5 Lessons from Marcus Aurelius for Modern Life	Letting go of what you cannot control and daily Stoic practice.	article	beginner	7	https://www.youtube.com/watch?v=I79TpDe3t2g	https://cdn.timewise.app/thumbs/stoic.jpg	\N	t	en	24600	4.80	10	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
34	9	Existentialism in 10 Minutes: Sartre and Freedom	Bad faith, the weight of freedom and radical responsibility.	podcast	intermediate	10	https://www.youtube.com/watch?v=xAWcbgFaW3c	https://cdn.timewise.app/thumbs/sartre.jpg	\N	f	en	8700	4.50	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
35	8	Cognitive Distortions: 7 Thinking Traps We All Fall Into	Catastrophizing, black-and-white thinking and mind reading — recognize them.	article	beginner	10	https://www.youtube.com/watch?v=HFqzBa2PGFE	https://cdn.timewise.app/thumbs/cognitive.jpg	\N	t	en	28300	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
36	8	The Science of Motivation: Why We Start and Why We Stop	Self-Determination Theory, dopamine and what sustains long-term effort.	article	intermediate	12	https://www.youtube.com/watch?v=tFrAi04MUt0	https://cdn.timewise.app/thumbs/motivation.jpg	\N	t	en	16400	4.60	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
37	8	5-Minute Box Breathing Reset	The 4-4-4-4 technique to reset focus and lower stress on demand.	exercise	beginner	5	https://www.youtube.com/watch?v=Auuk1y4DRgk	\N	\N	t	en	34200	4.90	10	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
38	8	10-Minute Body Scan Meditation	A mindful awareness sweep from head to toes.	exercise	beginner	10	https://www.youtube.com/watch?v=aU_hR-ycOWE	\N	\N	t	en	22100	4.70	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
39	8	Gratitude Journal: 3 Things Every Day	Structured daily writing prompt backed by positive psychology.	journaling	beginner	5	\N	\N	\N	t	en	16800	4.80	10	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
40	7	The Power of Compound Interest: Start Now	Concrete calculations showing the impact of starting early.	article	beginner	8	https://www.youtube.com/watch?v=8-Mq9HV2nXQ	https://cdn.timewise.app/thumbs/compound.jpg	\N	t	en	21500	4.90	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
41	7	Building a Monthly Budget: The 50/30/20 Rule	Split income into needs, wants and savings — a practical framework.	article	beginner	10	https://www.youtube.com/watch?v=u6XAPnuFjJc	https://cdn.timewise.app/thumbs/budget.jpg	\N	t	en	18600	4.50	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
42	9	Lean Startup: The Build-Measure-Learn Loop	MVP to first customer conversation — the methodology in 12 minutes.	article	intermediate	12	https://www.youtube.com/watch?v=tEmt1Znux58	https://cdn.timewise.app/thumbs/lean.jpg	\N	t	en	13200	4.70	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
43	7	Startup Valuation: Pre-money vs Post-money Explained	Core financial concepts every founder needs before investor meetings.	article	advanced	15	https://www.youtube.com/watch?v=QS2yDmWk0vs	https://cdn.timewise.app/thumbs/valuation.jpg	\N	t	en	6400	4.40	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
44	3	Atomic Habits by James Clear — 10-Minute Summary	The four laws of behavior change: cue, craving, response, reward. With concrete examples.	book_summary	beginner	10	https://www.youtube.com/watch?v=YT7tQzmGRLA	https://cdn.timewise.app/thumbs/atomic-habits.jpg	https://cdn.timewise.app/previews/atomic-habits-summary.mp4	t	en	38400	4.90	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
45	8	Thinking, Fast and Slow — Key Ideas in 12 Minutes	System 1 vs System 2 thinking, cognitive biases and how they shape every decision.	book_summary	intermediate	12	https://www.youtube.com/watch?v=uCDhxc-MkGQ	https://cdn.timewise.app/thumbs/thinking-fast-slow.jpg	https://cdn.timewise.app/previews/thinking-fast-slow-summary.mp4	t	en	29700	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
46	7	The Psychology of Money — Core Lessons	Wealth, greed and happiness: Morgan Housel's most important ideas distilled.	book_summary	beginner	10	https://www.youtube.com/watch?v=TgnsyS6OB1E	https://cdn.timewise.app/thumbs/psych-money.jpg	\N	t	en	24100	4.90	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
47	9	Meditations by Marcus Aurelius — A Modern Reading	Stoic philosophy made accessible: the most actionable passages with context.	book_summary	beginner	15	https://www.youtube.com/watch?v=Auuk1y4DRgk	https://cdn.timewise.app/thumbs/meditations.jpg	\N	t	en	17300	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
48	1	JavaScript Fundamentals: A Complete Beginner Course	Variables, functions, arrays, objects and DOM — the full foundation in one sitting.	tutorial	beginner	90	https://www.youtube.com/watch?v=PkZNo7MFNFg	https://cdn.timewise.app/thumbs/js-fundamentals.jpg	\N	t	en	9400	4.70	50	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
49	1	System Design Basics: How Big Apps Are Built	Load balancers, databases, caching and microservices — no code required.	article	intermediate	35	https://www.youtube.com/watch?v=i53Gi_K3o7I	https://cdn.timewise.app/thumbs/system-design.jpg	\N	t	en	7800	4.60	35	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
50	1	Build Your First REST API — Step by Step	Node.js + Express from scratch: routes, controllers, and JSON responses.	tutorial	intermediate	60	https://www.youtube.com/watch?v=fgTGADljAeg	https://cdn.timewise.app/thumbs/rest-api.jpg	\N	f	en	6500	4.80	40	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
51	2	Spanish Beginner Intensive: First 200 Words	Core vocabulary, pronunciation guide and your first 20 sentences.	flashcard	beginner	45	https://www.youtube.com/watch?v=oBkDeHLTSgI	https://cdn.timewise.app/thumbs/spanish.jpg	\N	t	en	11200	4.80	30	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
52	2	Master Japanese Hiragana in One Session	All 46 hiragana characters with memory hooks and writing practice.	exercise	beginner	60	https://www.youtube.com/watch?v=6p9Il_j0zjc	https://cdn.timewise.app/thumbs/hiragana.jpg	\N	t	en	8700	4.90	40	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
53	2	Advanced Conversation Techniques: Think in Your Target Language	Inner monologue practice, circumlocution and bridging strategies for B2+ learners.	video	advanced	40	https://www.youtube.com/watch?v=d0yGdNEWdn0	https://cdn.timewise.app/thumbs/advanced-convo.jpg	\N	f	en	5100	4.50	40	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
54	3	Build a Second Brain — Full System Overview	PARA method, capture habits, and retrieval-oriented note-taking in one deep session.	video	intermediate	75	https://www.youtube.com/watch?v=OP3dA2GcAh8	https://cdn.timewise.app/thumbs/second-brain.jpg	\N	f	en	8900	4.80	50	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
55	3	Time Blocking Masterclass: Design a Perfect Week	Calendar architecture, buffer blocks and energy-aware scheduling.	tutorial	intermediate	45	https://www.youtube.com/watch?v=jlHWNnMn3mM	https://cdn.timewise.app/thumbs/time-blocking.jpg	\N	t	en	7400	4.70	35	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
56	3	Annual Review Workshop: 12 Questions for Clarity	A guided self-reflection session — look back at the year and set real intentions.	journaling	beginner	90	\N	\N	\N	t	en	6200	4.90	50	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
57	5	30-Minute Full Body Workout: No Equipment	Warm-up, circuit training and cool-down — complete home workout.	exercise	beginner	30	https://medium.com/@yearcompass/annual-review-12-questions-for-clarity-7e4b2d8c9f01	https://cdn.timewise.app/thumbs/full-body.jpg	\N	t	en	14700	4.80	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
58	5	Nutrition 101: How to Actually Read Food Labels	Macros, micronutrients, serving sizes and marketing tricks explained.	article	beginner	20	https://www.youtube.com/watch?v=UItWltVZZmE	https://cdn.timewise.app/thumbs/nutrition.jpg	\N	t	en	12300	4.60	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
59	5	The Science of Stretching: A 45-Minute Mobility Routine	Anatomy-based flexibility work for desk workers and athletes alike.	video	beginner	45	https://www.youtube.com/watch?v=km03PGPYgfI	https://cdn.timewise.app/thumbs/mobility.jpg	\N	f	en	9100	4.70	35	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
60	4	Figure Drawing Fundamentals: Gesture to Structure	Proportions, gesture lines and simplified anatomy for character drawing.	video	intermediate	55	https://www.youtube.com/watch?v=qULTwquOuT4	https://cdn.timewise.app/thumbs/figure-drawing.jpg	\N	f	en	7600	4.80	40	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
61	4	Intro to Oil Painting: Alla Prima Technique	Wet-on-wet painting, color mixing and your first small study.	tutorial	intermediate	120	https://www.youtube.com/watch?v=74HR59yFZ7Y	https://cdn.timewise.app/thumbs/oil-painting.jpg	\N	f	en	4800	4.70	60	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
62	4	Knitting for Beginners: Cast On to First Scarf	All stitches you need, yarn selection and finishing a real project.	tutorial	beginner	90	https://www.youtube.com/watch?v=CqItPJiCHos	https://cdn.timewise.app/thumbs/knitting.jpg	\N	t	en	5500	4.80	50	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
63	6	Piano for Absolute Beginners: From Keys to First Song	Notes, hand position, both hands together — play a simple melody by the end.	tutorial	beginner	60	https://www.youtube.com/watch?v=USf_RO73nig	https://cdn.timewise.app/thumbs/piano-beginner.jpg	\N	f	en	9300	4.90	40	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
64	6	Music Production 101: Your First Beat in Garageband	Drums, bass, melody and basic arrangement — from zero to a finished loop.	tutorial	intermediate	90	https://www.youtube.com/watch?v=827i2JMbByY	https://cdn.timewise.app/thumbs/garageband.jpg	\N	f	en	6700	4.60	50	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
65	6	Advanced Guitar: Fingerpicking Patterns and Travis Picking	Pattern-based fingerpicking exercises for intermediate players.	tutorial	advanced	45	https://www.youtube.com/watch?v=mFcFFJolOxg	https://cdn.timewise.app/thumbs/fingerpicking.jpg	\N	t	en	4200	4.70	35	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
66	10	World History Timeline: From Ancient Civilizations to 1900	Key empires, events and turning points — the big picture in one session.	article	beginner	60	https://www.youtube.com/watch?v=YFmragGQFsM	https://cdn.timewise.app/thumbs/world-history.jpg	\N	t	en	8200	4.70	40	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
67	10	How Economies Work: A Visual Macro Introduction	GDP, inflation, interest rates and central banks explained accessibly.	video	beginner	35	https://www.youtube.com/watch?v=xuCn8ux2gbs	https://cdn.timewise.app/thumbs/macro.jpg	\N	t	en	7100	4.60	30	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
68	10	The Universe in 90 Minutes: Cosmology for Curious People	Big Bang, black holes, dark matter and the ultimate fate of the cosmos.	podcast	beginner	90	https://www.youtube.com/watch?v=PHe0bXAIuk0	https://cdn.timewise.app/thumbs/cosmology.jpg	\N	f	en	6300	4.80	50	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
69	9	Plato's Republic: The Core Argument in 30 Minutes	Justice, the city-soul analogy and the philosopher-king — the key ideas.	article	intermediate	30	https://www.youtube.com/watch?v=G-ESAbFLm1Q	https://cdn.timewise.app/thumbs/plato.jpg	\N	t	en	5800	4.60	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
70	9	Ethics Masterclass: Utilitarianism vs Deontology vs Virtue	Three major ethical frameworks, how they clash and how to apply them.	video	intermediate	55	https://www.youtube.com/watch?v=hAahsA-cTis	https://cdn.timewise.app/thumbs/ethics.jpg	\N	t	en	5200	4.70	40	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
71	8	CBT Toolkit: 8 Techniques You Can Use Today	Cognitive restructuring, behavioral activation and thought records explained.	article	intermediate	30	https://www.youtube.com/watch?v=MJHGe78H_As	https://cdn.timewise.app/thumbs/cbt.jpg	\N	t	en	10400	4.80	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
72	8	Attachment Theory: How Early Bonds Shape Adult Relationships	Secure, anxious, avoidant and disorganized — and what to do about them.	video	intermediate	40	https://www.youtube.com/watch?v=WjOowWxOXCg	https://cdn.timewise.app/thumbs/attachment.jpg	\N	t	en	8700	4.70	35	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
73	8	Deep Dive: The Psychology of Habits (Full Lecture)	Habit loops, cue-craving-response-reward, context dependency and relapse patterns.	video	advanced	120	https://www.youtube.com/watch?v=PZ7lDrwYdZc	https://cdn.timewise.app/thumbs/habit-psychology.jpg	\N	f	en	4600	4.80	60	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
74	7	Index Fund Investing: A Complete Beginner Walkthrough	ETFs, expense ratios, dollar-cost averaging — from zero to your first investment.	tutorial	beginner	40	https://www.youtube.com/watch?v=fwe-PjrX23o	https://cdn.timewise.app/thumbs/index-fund.jpg	\N	t	en	9700	4.90	35	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
75	7	Debt Payoff Strategy: Avalanche vs Snowball	Two proven methods compared with real math and psychological tradeoffs.	article	beginner	20	https://www.youtube.com/watch?v=E2AK5nFVIfg	https://cdn.timewise.app/thumbs/debt-payoff.jpg	\N	t	en	8300	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
76	7	Tax Basics Everyone Should Know: A Country-Agnostic Guide	Income tax, deductions, brackets and self-employment considerations.	article	intermediate	35	https://www.youtube.com/watch?v=wqVJxAruiSA	https://cdn.timewise.app/thumbs/tax-basics.jpg	\N	t	en	6100	4.50	30	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
77	8	45-Minute Deep Mindfulness Session: Breath + Body + Open Awareness	A guided progression through three classic meditation techniques.	exercise	intermediate	45	https://www.youtube.com/watch?v=inpok4MKVLM	https://cdn.timewise.app/thumbs/deep-mindfulness.jpg	\N	t	en	7900	4.90	35	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
78	8	Loving-Kindness Meditation (Metta): A Beginner Session	The classic compassion practice — for yourself and others.	exercise	beginner	20	https://www.youtube.com/watch?v=sz7cpV7ERsM	https://cdn.timewise.app/thumbs/metta.jpg	\N	t	en	7200	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
79	9	Zero to Product: Finding and Validating Your Idea	Jobs-to-be-done, problem interviews, landing page MVPs — the validation sprint.	tutorial	intermediate	60	https://www.youtube.com/watch?v=q0Wq5wUaALQ	https://cdn.timewise.app/thumbs/validation.jpg	\N	f	en	5900	4.70	40	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
80	9	Growth Marketing 101: Channels, Loops and Retention	Acquisition, activation, retention and referral — the full AARRR funnel.	article	intermediate	30	https://www.youtube.com/watch?v=vnISFuMWYsY	https://cdn.timewise.app/thumbs/growth-marketing.jpg	\N	t	en	5400	4.60	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
81	7	Fundraising Fundamentals: How VC Rounds Actually Work	Pre-seed to Series B — term sheets, dilution and what investors really want.	article	advanced	45	https://www.youtube.com/watch?v=677ZtSMr4-4	https://cdn.timewise.app/thumbs/fundraising.jpg	\N	t	en	3900	4.50	40	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
82	\N	Meditations	Marcus Aurelius's private journal — stoic reflections on duty, impermanence and inner freedom.	book	beginner	180	https://standardebooks.org/ebooks/marcus-aurelius/meditations/george-long	https://cdn.timewise.app/thumbs/book-meditations.jpg	\N	t	en	42000	4.90	60	2026-03-21 00:46:13.125318+03	t	https://standardebooks.org/ebooks/marcus-aurelius/meditations/george-long	\N	\N	185
83	\N	The Art of War	Sun Tzu's ancient treatise on strategy, conflict and leadership. Short but dense.	book	beginner	60	https://www.gutenberg.org/ebooks/132	https://cdn.timewise.app/thumbs/book-art-of-war.jpg	\N	t	en	38000	4.70	30	2026-03-21 00:46:13.125318+03	t	https://www.gutenberg.org/ebooks/132	\N	\N	68
84	\N	The Adventures of Sherlock Holmes	Conan Doyle's classic collection of twelve detective short stories. Perfect for long breaks.	book	beginner	360	https://standardebooks.org/ebooks/arthur-conan-doyle/the-adventures-of-sherlock-holmes	https://cdn.timewise.app/thumbs/book-sherlock.jpg	\N	t	en	29000	4.80	80	2026-03-21 00:46:13.125318+03	t	https://standardebooks.org/ebooks/arthur-conan-doyle/the-adventures-of-sherlock-holmes	\N	\N	307
85	\N	Frankenstein	Mary Shelley's gothic masterpiece about ambition, creation and what it means to be human.	book	beginner	240	https://standardebooks.org/ebooks/mary-shelley/frankenstein	https://cdn.timewise.app/thumbs/book-frankenstein.jpg	\N	t	en	24000	4.60	60	2026-03-21 00:46:13.125318+03	t	https://standardebooks.org/ebooks/mary-shelley/frankenstein	\N	\N	280
86	\N	The Strange Case of Dr Jekyll and Mr Hyde	Stevenson's novella on duality, repression and the dark side of human nature.	book	beginner	90	https://standardebooks.org/ebooks/robert-louis-stevenson/the-strange-case-of-dr-jekyll-and-mr-hyde	https://cdn.timewise.app/thumbs/book-jekyll.jpg	\N	t	en	21000	4.70	40	2026-03-21 00:46:13.125318+03	t	https://standardebooks.org/ebooks/robert-louis-stevenson/the-strange-case-of-dr-jekyll-and-mr-hyde	\N	\N	141
87	\N	Walden	Thoreau's account of two years living simply in the woods — a meditation on self-reliance.	book	intermediate	300	https://standardebooks.org/ebooks/henry-david-thoreau/walden	https://cdn.timewise.app/thumbs/book-walden.jpg	\N	t	en	17000	4.50	70	2026-03-21 00:46:13.125318+03	t	https://standardebooks.org/ebooks/henry-david-thoreau/walden	\N	\N	336
88	\N	The Prince	Machiavelli's unflinching guide to political power — ruthless realism in 26 short chapters.	book	intermediate	150	https://www.gutenberg.org/ebooks/1232	https://cdn.timewise.app/thumbs/book-prince.jpg	\N	t	en	19000	4.60	45	2026-03-21 00:46:13.125318+03	t	https://www.gutenberg.org/ebooks/1232	\N	\N	140
89	\N	The Metamorphosis	Kafka's surrealist novella — waking up as a giant insect and what follows.	book	beginner	90	https://standardebooks.org/ebooks/franz-kafka/the-metamorphosis/ian-johnston	https://cdn.timewise.app/thumbs/book-metamorphosis.jpg	\N	t	en	23000	4.80	40	2026-03-21 00:46:13.125318+03	t	https://standardebooks.org/ebooks/franz-kafka/the-metamorphosis/ian-johnston	\N	\N	101
90	\N	The Wealth of Nations (Book I)	Adam Smith's foundational economics text — Book I covers division of labour and value.	book	advanced	420	https://www.gutenberg.org/ebooks/3300	https://cdn.timewise.app/thumbs/book-wealth-nations.jpg	\N	t	en	12000	4.40	90	2026-03-21 00:46:13.125318+03	t	https://www.gutenberg.org/ebooks/3300	\N	\N	510
91	\N	Pride and Prejudice	Jane Austen's witty romance and social critique — one of the most beloved novels in English.	book	beginner	480	https://standardebooks.org/ebooks/jane-austen/pride-and-prejudice	https://cdn.timewise.app/thumbs/book-pride-prejudice.jpg	\N	t	en	33000	4.90	80	2026-03-21 00:46:13.125318+03	t	https://standardebooks.org/ebooks/jane-austen/pride-and-prejudice	\N	\N	432
92	\N	2048	Slide tiles to combine numbers and reach the 2048 tile. Addictive logic puzzle.	game	beginner	15	https://play2048.co/	https://cdn.timewise.app/thumbs/game-2048.jpg	\N	t	en	95000	4.80	10	2026-03-21 00:46:13.125318+03	t	\N	<html><head><meta charset="UTF-8"><title>2048</title><style>*{box-sizing:border-box;margin:0;padding:0}body{background:#faf8ef;font-family:Arial,sans-serif;display:flex;flex-direction:column;align-items:center;padding:20px}h1{color:#776e65;font-size:36px;margin-bottom:8px}.score-box{background:#bbada0;color:#fff;border-radius:6px;padding:8px 16px;font-size:18px;font-weight:bold;margin-bottom:12px}#board{display:grid;grid-template-columns:repeat(4,80px);gap:8px;background:#bbada0;padding:10px;border-radius:10px}.cell{width:80px;height:80px;border-radius:6px;display:flex;align-items:center;justify-content:center;font-size:24px;font-weight:bold;background:#cdc1b4;color:#776e65;transition:all .1s}.c2{background:#eee4da}.c4{background:#ede0c8}.c8{background:#f2b179;color:#fff}.c16{background:#f59563;color:#fff}.c32{background:#f67c5f;color:#fff}.c64{background:#f65e3b;color:#fff}.c128{background:#edcf72;color:#fff;font-size:20px}.c256{background:#edcc61;color:#fff;font-size:20px}.c512{background:#edc850;color:#fff;font-size:18px}.c1024{background:#edc53f;color:#fff;font-size:16px}.c2048{background:#edc22e;color:#fff;font-size:16px}.msg{margin-top:16px;font-size:16px;color:#776e65}button{margin-top:10px;padding:10px 24px;background:#8f7a66;color:#fff;border:none;border-radius:6px;font-size:16px;cursor:pointer}</style></head><body><h1>2048</h1><div class="score-box">Score: <span id="sc">0</span></div><div id="board"></div><div class="msg" id="msg"></div><button onclick="init()">New Game</button><script>let b,sc;function init(){b=Array.from({length:4},()=>Array(4).fill(0));sc=0;document.getElementById("sc").textContent=0;document.getElementById("msg").textContent="";add();add();draw()}function add(){let e=[];for(let r=0;r<4;r++)for(let c=0;c<4;c++)if(!b[r][c])e.push([r,c]);if(!e.length)return;let[r,c]=e[Math.floor(Math.random()*e.length)];b[r][c]=Math.random()<.9?2:4}function draw(){let d=document.getElementById("board");d.innerHTML="";for(let r=0;r<4;r++)for(let c=0;c<4;c++){let v=b[r][c],el=document.createElement("div");el.className="cell"+(v?" c"+v:"");el.textContent=v||"";d.appendChild(el)}}function move(dir){let moved=false,prev=JSON.stringify(b);if(dir===0)for(let c=0;c<4;c++){let col=b.map(r=>r[c]).filter(v=>v);col=merge(col);while(col.length<4)col.push(0);for(let r=0;r<4;r++)b[r][c]=col[r]}else if(dir===1)for(let c=0;c<4;c++){let col=b.map(r=>r[c]).filter(v=>v).reverse();col=merge(col);while(col.length<4)col.push(0);col.reverse();for(let r=0;r<4;r++)b[r][c]=col[r]}else if(dir===2)for(let r=0;r<4;r++){let row=b[r].filter(v=>v);row=merge(row);while(row.length<4)row.push(0);b[r]=row}else for(let r=0;r<4;r++){let row=b[r].filter(v=>v).reverse();row=merge(row);while(row.length<4)row.push(0);row.reverse();b[r]=row}if(JSON.stringify(b)!==prev){add();draw();if(b.flat().includes(2048))document.getElementById("msg").textContent="You reached 2048! 🎉"}}function merge(a){for(let i=0;i<a.length-1;i++)if(a[i]===a[i+1]){sc+=a[i]*2;document.getElementById("sc").textContent=sc;a[i]*=2;a.splice(i+1,1)}return a}document.addEventListener("keydown",e=>{if(e.key==="ArrowUp")move(0);else if(e.key==="ArrowDown")move(1);else if(e.key==="ArrowLeft")move(2);else if(e.key==="ArrowRight")move(3)});init();</script></body></html>	\N	\N
93	\N	Minesweeper	Uncover all safe tiles without hitting a mine. The timeless strategy classic.	game	beginner	20	https://minesweeper.online/	https://cdn.timewise.app/thumbs/game-minesweeper.jpg	\N	t	en	72000	4.70	10	2026-03-21 00:46:13.125318+03	t	\N	<html><head><meta charset="UTF-8"><title>Minesweeper</title><style>*{box-sizing:border-box;margin:0;padding:0}body{background:#c0c0c0;font-family:Arial,sans-serif;display:flex;flex-direction:column;align-items:center;padding:20px}h1{color:#333;margin-bottom:12px}.info{display:flex;gap:20px;margin-bottom:10px;font-size:16px;font-weight:bold}#board{display:grid;gap:2px;margin-bottom:10px}.cell{width:34px;height:34px;background:#bdbdbd;border:3px outset #fff;font-size:14px;font-weight:bold;cursor:pointer;display:flex;align-items:center;justify-content:center;user-select:none}.cell.open{background:#e0e0e0;border:1px solid #999}.cell.mine{background:#f44336}.cell.flag{background:#bdbdbd}.c1{color:#1565c0}.c2{color:#2e7d32}.c3{color:#c62828}.c4{color:#283593}.c5{color:#6d1f00}.c6{color:#006064}.c7{color:#4a148c}.c8{color:#212121}button{padding:8px 20px;font-size:14px;cursor:pointer;border-radius:4px;border:2px outset #fff;background:#bdbdbd}</style></head><body><h1>💣 Minesweeper</h1><div class="info"><span>Mines: <span id="mc">10</span></span><span>Time: <span id="tm">0</span>s</span></div><div id="board"></div><div id="msg" style="margin:10px;font-size:16px;font-weight:bold"></div><button onclick="init()">New Game</button><script>const R=9,C=9,M=10;let grid,revealed,flagged,gameOver,timer,elapsed;function init(){grid=Array.from({length:R},()=>Array(C).fill(0));revealed=Array.from({length:R},()=>Array(C).fill(false));flagged=Array.from({length:R},()=>Array(C).fill(false));gameOver=false;elapsed=0;clearInterval(timer);document.getElementById("mc").textContent=M;document.getElementById("tm").textContent=0;document.getElementById("msg").textContent="";let mines=0,placed=[];while(mines<M){let r=Math.floor(Math.random()*R),c=Math.floor(Math.random()*C),k=r*C+c;if(!placed.includes(k)){placed.push(k);grid[r][c]=-1;mines++}}for(let r=0;r<R;r++)for(let c=0;c<C;c++)if(grid[r][c]!==-1){let n=0;for(let dr=-1;dr<=1;dr++)for(let dc=-1;dc<=1;dc++){let nr=r+dr,nc=c+dc;if(nr>=0&&nr<R&&nc>=0&&nc<C&&grid[nr][nc]===-1)n++}grid[r][c]=n}draw()}function draw(){let b=document.getElementById("board");b.style.gridTemplateColumns=`repeat(${C},34px)`;b.innerHTML="";for(let r=0;r<R;r++)for(let c=0;c<C;c++){let el=document.createElement("div");el.className="cell";el.dataset.r=r;el.dataset.c=c;if(revealed[r][c]){el.classList.add("open");if(grid[r][c]===-1)el.classList.add("mine"),el.textContent="💣";else if(grid[r][c]>0)el.classList.add("c"+grid[r][c]),el.textContent=grid[r][c]}else if(flagged[r][c])el.textContent="🚩";el.addEventListener("click",onClick);el.addEventListener("contextmenu",onFlag);b.appendChild(el)}}function onClick(e){let r=+e.currentTarget.dataset.r,c=+e.currentTarget.dataset.c;if(gameOver||revealed[r][c]||flagged[r][c])return;if(elapsed===0){timer=setInterval(()=>{elapsed++;document.getElementById("tm").textContent=elapsed},1000)}if(grid[r][c]===-1){gameOver=true;clearInterval(timer);reveal_all();document.getElementById("msg").textContent="💥 Game Over!";return}flood(r,c);draw();check_win()}function onFlag(e){e.preventDefault();let r=+e.currentTarget.dataset.r,c=+e.currentTarget.dataset.c;if(gameOver||revealed[r][c])return;flagged[r][c]=!flagged[r][c];draw()}function flood(r,c){if(r<0||r>=R||c<0||c>=C||revealed[r][c])return;revealed[r][c]=true;if(grid[r][c]===0)for(let dr=-1;dr<=1;dr++)for(let dc=-1;dc<=1;dc++)flood(r+dr,c+dc)}function reveal_all(){for(let r=0;r<R;r++)for(let c=0;c<C;c++)if(grid[r][c]===-1)revealed[r][c]=true;draw()}function check_win(){let cnt=0;for(let r=0;r<R;r++)for(let c=0;c<C;c++)if(!revealed[r][c])cnt++;if(cnt===M){gameOver=true;clearInterval(timer);document.getElementById("msg").textContent="🎉 You Win!"}}init();</script></body></html>	\N	\N
121	\N	Abstract: The Art of Design — Tinker Hatfield	Nike's legendary shoe designer on creativity, constraint and cultural impact.	documentary	beginner	44	https://www.youtube.com/watch?v=Gt9vAPUmON8	https://cdn.timewise.app/thumbs/doc-tinker.jpg	\N	f	en	1500000	4.70	35	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
122	10	The French Revolution: Causes, Events and Legacy	From Estates-General to the guillotine — the complete arc of 1789.	video	beginner	18	https://www.youtube.com/watch?v=5fJl_ZX91l0	https://cdn.timewise.app/thumbs/hist-french-rev.jpg	\N	t	en	3200000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
123	10	World War I Explained: Causes, War, Aftermath	The war that reshaped the map of the world — from Sarajevo to Versailles.	video	beginner	20	https://www.youtube.com/watch?v=dHSQAEam2yc	https://cdn.timewise.app/thumbs/hist-ww1.jpg	\N	t	en	4100000	4.90	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
124	10	World War II: A Complete Overview	The second global conflict — causes, major campaigns and the post-war order.	video	beginner	25	https://www.youtube.com/watch?v=fo2Rb9h788s	https://cdn.timewise.app/thumbs/hist-ww2.jpg	\N	t	en	6800000	4.90	30	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
94	\N	Snake	Guide the growing snake to eat food without hitting walls or yourself.	game	beginner	10	https://www.google.com/fbx?fbx=snake_arcade	https://cdn.timewise.app/thumbs/game-snake.jpg	\N	t	en	88000	4.60	10	2026-03-21 00:46:13.125318+03	t	\N	<html><head><meta charset="UTF-8"><title>Snake</title><style>*{margin:0;padding:0;box-sizing:border-box}body{background:#1a1a2e;display:flex;flex-direction:column;align-items:center;justify-content:center;height:100vh;font-family:Arial,sans-serif;color:#eee}h1{font-size:28px;margin-bottom:8px;color:#0f3460}canvas{border:3px solid #0f3460;border-radius:4px;background:#16213e}.info{display:flex;gap:30px;margin-bottom:8px;font-size:16px}.msg{margin-top:10px;font-size:16px;min-height:22px}button{margin-top:8px;padding:8px 24px;background:#0f3460;color:#fff;border:none;border-radius:6px;font-size:15px;cursor:pointer}</style></head><body><h1>🐍 Snake</h1><div class="info"><span>Score: <span id="sc">0</span></span><span>Best: <span id="best">0</span></span></div><canvas id="c" width="360" height="360"></canvas><div class="msg" id="msg">Arrow keys to move</div><button onclick="start()">Start</button><script>const canvas=document.getElementById("c"),ctx=canvas.getContext("2d"),SZ=20,COLS=18,ROWS=18;let snake,dir,food,running,score,best=0,loop;function start(){snake=[{x:9,y:9},{x:8,y:9},{x:7,y:9}];dir={x:1,y:0};score=0;document.getElementById("sc").textContent=0;document.getElementById("msg").textContent="";place_food();clearInterval(loop);running=true;loop=setInterval(tick,120)}function place_food(){do{food={x:Math.floor(Math.random()*COLS),y:Math.floor(Math.random()*ROWS)}}while(snake.some(s=>s.x===food.x&&s.y===food.y))}function tick(){if(!running)return;let head={x:snake[0].x+dir.x,y:snake[0].y+dir.y};if(head.x<0||head.x>=COLS||head.y<0||head.y>=ROWS||snake.some(s=>s.x===head.x&&s.y===head.y)){running=false;clearInterval(loop);document.getElementById("msg").textContent="Game Over! 🐍";return}snake.unshift(head);if(head.x===food.x&&head.y===food.y){score++;if(score>best){best=score;document.getElementById("best").textContent=best}document.getElementById("sc").textContent=score;place_food()}else snake.pop();draw()}function draw(){ctx.fillStyle="#16213e";ctx.fillRect(0,0,canvas.width,canvas.height);ctx.fillStyle="#0f3460";ctx.fillRect(food.x*SZ,food.y*SZ,SZ-2,SZ-2);snake.forEach((s,i)=>{ctx.fillStyle=i===0?"#e94560":"#0f3460";ctx.fillRect(s.x*SZ+1,s.y*SZ+1,SZ-2,SZ-2)})}document.addEventListener("keydown",e=>{if(e.key==="ArrowUp"&&dir.y!==1)dir={x:0,y:-1};else if(e.key==="ArrowDown"&&dir.y!==-1)dir={x:0,y:1};else if(e.key==="ArrowLeft"&&dir.x!==1)dir={x:-1,y:0};else if(e.key==="ArrowRight"&&dir.x!==-1)dir={x:1,y:0}});draw();</script></body></html>	\N	\N
95	\N	Sudoku	Fill the 9×9 grid so every row, column and 3×3 box contains 1–9.	game	intermediate	30	https://sudoku.com/	https://cdn.timewise.app/thumbs/game-sudoku.jpg	\N	t	en	81000	4.90	15	2026-03-21 00:46:13.125318+03	t	\N	<html><head><meta charset="UTF-8"><title>Sudoku</title><style>*{box-sizing:border-box;margin:0;padding:0}body{background:#f5f5f5;font-family:Arial,sans-serif;display:flex;flex-direction:column;align-items:center;padding:20px}h1{margin-bottom:12px;color:#333}table{border-collapse:collapse;margin-bottom:12px}td{width:42px;height:42px;border:1px solid #bbb;text-align:center;vertical-align:middle}.thick-right{border-right:3px solid #333}.thick-bottom{border-bottom:3px solid #333}input{width:100%;height:100%;border:none;background:transparent;text-align:center;font-size:20px;color:#1a237e;outline:none}input.given{color:#333;font-weight:bold;pointer-events:none}input.error{background:#ffcdd2}input.highlight{background:#e3f2fd}.btn-row{display:flex;gap:10px}button{padding:8px 20px;border:none;border-radius:6px;background:#3949ab;color:#fff;font-size:14px;cursor:pointer}.msg{margin-top:10px;font-size:15px;font-weight:bold;color:#2e7d32}</style></head><body><h1>🔢 Sudoku</h1><table id="grid"></table><div class="btn-row"><button onclick="check()">Check</button><button onclick="solve_reveal()">Solve</button><button onclick="newGame()">New Game</button></div><div class="msg" id="msg"></div><script>const puzzles=["530070000600195000098000060800060003400803001700020006060000280000419005000080079","200080300060070084030500209000105408000000000402706000301007040720040060004010003","000000907000420180000705026100904000050000040000507009920108000034059000507000000"];let given,solution;function newGame(){document.getElementById("msg").textContent="";let idx=Math.floor(Math.random()*puzzles.length);given=puzzles[idx].split("").map(Number);buildGrid(given)}function buildGrid(g){let tbl=document.getElementById("grid");tbl.innerHTML="";for(let r=0;r<9;r++){let tr=document.createElement("tr");for(let c=0;c<9;c++){let td=document.createElement("td");if(c===2||c===5)td.classList.add("thick-right");if(r===2||r===5)td.classList.add("thick-bottom");let inp=document.createElement("input");inp.type="text";inp.maxLength=1;inp.dataset.i=r*9+c;if(g[r*9+c]){inp.value=g[r*9+c];inp.classList.add("given")}else{inp.addEventListener("input",onInput)}td.appendChild(inp);tr.appendChild(td)}tbl.appendChild(tr)}}function onInput(e){e.target.value=e.target.value.replace(/[^1-9]/,"");e.target.classList.remove("error")}function check(){let ok=true;for(let r=0;r<9;r++)for(let c=0;c<9;c++){let inp=document.querySelector(`input[data-i="${r*9+c}"]`);if(!inp.classList.contains("given")&&inp.value){let v=+inp.value;if(!valid_place(r,c,v)){inp.classList.add("error");ok=false}}}document.getElementById("msg").textContent=ok?"Looking good so far! ✓":"Some cells have errors ✗"}function valid_place(r,c,v){for(let i=0;i<9;i++){let inp_r=document.querySelector(`input[data-i="${r*9+i}"]`);if(i!==c&&inp_r&&+inp_r.value===v)return false;let inp_c=document.querySelector(`input[data-i="${i*9+c}"]`);if(i!==r&&inp_c&&+inp_c.value===v)return false}let sr=Math.floor(r/3)*3,sc=Math.floor(c/3)*3;for(let dr=0;dr<3;dr++)for(let dc=0;dc<3;dc++){let nr=sr+dr,nc=sc+dc;if(nr===r&&nc===c)continue;let inp=document.querySelector(`input[data-i="${nr*9+nc}"]`);if(inp&&+inp.value===v)return false}return true}function solve_reveal(){newGame()}newGame();</script></body></html>	\N	\N
96	\N	Tetris	Stack falling blocks to clear lines. The most played game of all time.	game	beginner	20	https://tetris.com/play-tetris	https://cdn.timewise.app/thumbs/game-tetris.jpg	\N	t	en	120000	4.90	10	2026-03-21 00:46:13.125318+03	t	\N	<html><head><meta charset="UTF-8"><title>Tetris</title><style>*{margin:0;padding:0;box-sizing:border-box}body{background:#0d0d0d;display:flex;align-items:center;justify-content:center;height:100vh;font-family:Arial,sans-serif;color:#fff;gap:20px}canvas{border:2px solid #444}.side{display:flex;flex-direction:column;gap:16px;font-size:14px}.label{color:#888;font-size:12px;text-transform:uppercase}.val{font-size:24px;font-weight:bold;color:#0ff}button{padding:8px 16px;background:#222;color:#fff;border:1px solid #444;border-radius:4px;cursor:pointer;font-size:13px}.msg{position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);background:rgba(0,0,0,.8);padding:20px 30px;border-radius:8px;font-size:20px;text-align:center;display:none}</style></head><body><canvas id="c" width="200" height="400"></canvas><div class="side"><div><div class="label">Score</div><div class="val" id="sc">0</div></div><div><div class="label">Lines</div><div class="val" id="ln">0</div></div><div><div class="label">Level</div><div class="val" id="lv">1</div></div><div><button onclick="start()">Start / Restart</button></div><div style="font-size:12px;color:#666">← → Move<br>↑ Rotate<br>↓ Drop</div></div><div class="msg" id="msg"></div><script>const C=document.getElementById("c"),ctx=C.getContext("2d"),COLS=10,ROWS=20,SZ=20;const PIECES=[[[[1,1,1,1]]],[[[1,1],[1,1]]],[[[1,0,0],[1,1,1]]],[[[0,0,1],[1,1,1]]],[[[0,1,1],[1,1,0]]],[[[1,1,0],[0,1,1]]],[[[0,1,0],[1,1,1]]]];const COLORS=["#0ff","#ff0","#f80","#00f","#0f0","#f00","#f0f"];let board,cur,curX,curY,curType,score,lines,level,running,interval;function start(){board=Array.from({length:ROWS},()=>Array(COLS).fill(0));score=0;lines=0;level=1;document.getElementById("sc").textContent=0;document.getElementById("ln").textContent=0;document.getElementById("lv").textContent=1;document.getElementById("msg").style.display="none";running=true;clearInterval(interval);spawn();interval=setInterval(tick,500)}function spawn(){curType=Math.floor(Math.random()*PIECES.length);cur=PIECES[curType][0];curX=Math.floor((COLS-cur[0].length)/2);curY=0;if(collide(curX,curY,cur)){running=false;clearInterval(interval);let m=document.getElementById("msg");m.textContent="Game Over!\nScore: "+score;m.style.display="block"}}function rotate(p){return p[0].map((_,c)=>p.map(r=>r[c]).reverse())}function collide(x,y,p){for(let r=0;r<p.length;r++)for(let c=0;c<p[r].length;c++)if(p[r][c]&&(x+c<0||x+c>=COLS||y+r>=ROWS||board[y+r][x+c]))return true;return false}function place(){for(let r=0;r<cur.length;r++)for(let c=0;c<cur[r].length;c++)if(cur[r][c])board[curY+r][curX+c]=curType+1;let cleared=0;for(let r=ROWS-1;r>=0;r--)if(board[r].every(v=>v)){board.splice(r,1);board.unshift(Array(COLS).fill(0));cleared++;r++}if(cleared){lines+=cleared;score+=cleared*100*level;level=Math.floor(lines/10)+1;clearInterval(interval);interval=setInterval(tick,Math.max(100,500-level*40));document.getElementById("ln").textContent=lines;document.getElementById("lv").textContent=level;document.getElementById("sc").textContent=score}spawn()}function tick(){if(!running)return;if(!collide(curX,curY+1,cur))curY++;else place();draw()}function draw(){ctx.fillStyle="#111";ctx.fillRect(0,0,C.width,C.height);for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++)if(board[r][c]){ctx.fillStyle=COLORS[board[r][c]-1];ctx.fillRect(c*SZ+1,r*SZ+1,SZ-2,SZ-2)}if(cur)for(let r=0;r<cur.length;r++)for(let c=0;c<cur[r].length;c++)if(cur[r][c]){ctx.fillStyle=COLORS[curType];ctx.fillRect((curX+c)*SZ+1,(curY+r)*SZ+1,SZ-2,SZ-2)}}document.addEventListener("keydown",e=>{if(!running)return;if(e.key==="ArrowLeft"&&!collide(curX-1,curY,cur))curX--;else if(e.key==="ArrowRight"&&!collide(curX+1,curY,cur))curX++;else if(e.key==="ArrowUp"){let rot=rotate(cur);if(!collide(curX,curY,rot))cur=rot}else if(e.key==="ArrowDown"&&!collide(curX,curY+1,cur))curY++;e.preventDefault();draw()});draw();</script></body></html>	\N	\N
97	\N	Memory Match	Flip cards and find matching pairs. Trains short-term memory and concentration.	game	beginner	10	https://www.memozor.com/memory-games	https://cdn.timewise.app/thumbs/game-memory.jpg	\N	t	en	53000	4.50	10	2026-03-21 00:46:13.125318+03	t	\N	<html><head><meta charset="UTF-8"><title>Memory Match</title><style>*{box-sizing:border-box;margin:0;padding:0}body{background:#1a1a2e;font-family:Arial,sans-serif;color:#eee;display:flex;flex-direction:column;align-items:center;padding:20px}h1{margin-bottom:8px}#info{display:flex;gap:24px;margin-bottom:14px;font-size:16px}#board{display:grid;grid-template-columns:repeat(4,80px);gap:10px}.card{width:80px;height:80px;background:#16213e;border:2px solid #0f3460;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:32px;cursor:pointer;transition:transform .2s;user-select:none}.card.flipped,.card.matched{background:#0f3460}.card.matched{opacity:.6;pointer-events:none}#msg{margin-top:14px;font-size:18px;font-weight:bold;color:#0ff}button{margin-top:10px;padding:8px 22px;background:#0f3460;color:#fff;border:none;border-radius:6px;cursor:pointer;font-size:14px}</style></head><body><h1>🃏 Memory Match</h1><div id="info"><span>Moves: <span id="mv">0</span></span><span>Matched: <span id="mt">0</span>/8</span></div><div id="board"></div><div id="msg"></div><button onclick="init()">New Game</button><script>const EMOJIS=["🐶","🐱","🦊","🐸","🦁","🐧","🦋","🌸"];let cards,flipped,matched,moves,lock;function init(){let pool=[...EMOJIS,...EMOJIS].sort(()=>Math.random()-.5);cards=pool;flipped=[];matched=0;moves=0;lock=false;document.getElementById("mv").textContent=0;document.getElementById("mt").textContent=0;document.getElementById("msg").textContent="";let b=document.getElementById("board");b.innerHTML="";cards.forEach((em,i)=>{let d=document.createElement("div");d.className="card";d.dataset.i=i;d.dataset.em=em;d.textContent="";d.addEventListener("click",onFlip);b.appendChild(d)})}function onFlip(e){let d=e.currentTarget;if(lock||d.classList.contains("flipped")||d.classList.contains("matched"))return;d.classList.add("flipped");d.textContent=d.dataset.em;flipped.push(d);if(flipped.length===2){moves++;document.getElementById("mv").textContent=moves;lock=true;setTimeout(check,700)}}function check(){let[a,b]=flipped;if(a.dataset.em===b.dataset.em){a.classList.add("matched");b.classList.add("matched");matched++;document.getElementById("mt").textContent=matched;if(matched===8)document.getElementById("msg").textContent="🎉 You won in "+moves+" moves!"}else{a.classList.remove("flipped");b.classList.remove("flipped");a.textContent="";b.textContent=""}flipped=[];lock=false}init();</script></body></html>	\N	\N
98	\N	Word Scramble	Unscramble the letters to find the hidden word. Vocabulary and pattern recognition.	game	beginner	10	https://wordscramble.net/	https://cdn.timewise.app/thumbs/game-word-scramble.jpg	\N	t	en	44000	4.40	10	2026-03-21 00:46:13.125318+03	t	\N	<html><head><meta charset="UTF-8"><title>Word Scramble</title><style>*{box-sizing:border-box;margin:0;padding:0}body{background:#fffde7;font-family:Arial,sans-serif;display:flex;flex-direction:column;align-items:center;padding:30px;min-height:100vh}h1{color:#f57f17;margin-bottom:8px}.category{color:#888;margin-bottom:20px;font-size:14px}.scrambled{font-size:42px;font-weight:bold;letter-spacing:8px;color:#e65100;margin-bottom:24px}.hint{color:#aaa;font-size:13px;margin-bottom:20px;font-style:italic}input{font-size:22px;padding:10px 18px;border:2px solid #f57f17;border-radius:8px;outline:none;text-align:center;width:240px;margin-bottom:12px}button{padding:10px 24px;background:#f57f17;color:#fff;border:none;border-radius:8px;font-size:16px;cursor:pointer;margin:0 6px}.result{margin-top:16px;font-size:20px;font-weight:bold;min-height:28px}.score{margin-top:8px;color:#555;font-size:15px}</style></head><body><h1>🔤 Word Scramble</h1><div class="category" id="cat"></div><div class="scrambled" id="scr"></div><div class="hint" id="hint"></div><input id="ans" placeholder="Your answer" onkeydown="if(event.key==='Enter')check()"><br><button onclick="check()">Check</button><button onclick="skip()">Skip →</button><div class="result" id="res"></div><div class="score">Score: <span id="sc">0</span> | Skipped: <span id="sk">0</span></div><script>const WORDS=[{w:"PYTHON",h:"A popular programming language",c:"Tech"},{w:"STOIC",h:"A philosophy about endurance",c:"Philosophy"},{w:"BUDGET",h:"A financial plan",c:"Finance"},{w:"NEURON",h:"Brain cell",c:"Science"},{w:"CANVAS",h:"Artist painting surface",c:"Arts"},{w:"SONATA",h:"A musical composition",c:"Music"},{w:"OXYGEN",h:"Element we breathe",c:"Science"},{w:"SYNTAX",h:"Rules of a language",c:"Tech"},{w:"VIRTUE",h:"Moral excellence",c:"Philosophy"},{w:"RHYTHM",h:"Beat in music",c:"Music"},{w:"FRACTAL",h:"Self-similar mathematical pattern",c:"Math"},{w:"MEMOIR",h:"A personal account",c:"Literature"},{w:"GALAXY",h:"A system of stars",c:"Space"},{w:"ENZYME",h:"Biological catalyst",c:"Biology"},{w:"SONNET",h:"A 14-line poem",c:"Literature"}];let idx=0,score=0,skipped=0,order;function scramble(w){let a=w.split("");for(let i=a.length-1;i>0;i--){let j=Math.floor(Math.random()*(i+1));[a[i],a[j]]=[a[j],a[i]]}return a.join("")===w?scramble(w):a.join("")}function init(){order=[...WORDS].sort(()=>Math.random()-.5);idx=0;score=0;skipped=0;show()}function show(){if(idx>=order.length){document.getElementById("res").textContent="🏁 Done! Score: "+score;return}let{w,h,c}=order[idx];document.getElementById("cat").textContent="Category: "+c;document.getElementById("scr").textContent=scramble(w);document.getElementById("hint").textContent="Hint: "+h;document.getElementById("ans").value="";document.getElementById("res").textContent="";document.getElementById("ans").focus()}function check(){let ans=document.getElementById("ans").value.trim().toUpperCase();if(ans===order[idx].w){score++;document.getElementById("sc").textContent=score;document.getElementById("res").textContent="✅ Correct!";setTimeout(()=>{idx++;show()},800)}else{document.getElementById("res").textContent="❌ Try again!"}}function skip(){skipped++;document.getElementById("sk").textContent=skipped;document.getElementById("res").textContent="Answer: "+order[idx].w;setTimeout(()=>{idx++;show()},1000)}init();</script></body></html>	\N	\N
99	\N	Typing Speed Test	Type the paragraph as fast and accurately as you can. Great for warm-up.	game	beginner	5	https://monkeytype.com/	https://cdn.timewise.app/thumbs/game-typing.jpg	\N	t	en	67000	4.70	10	2026-03-21 00:46:13.125318+03	t	\N	<html><head><meta charset="UTF-8"><title>Typing Test</title><style>*{box-sizing:border-box;margin:0;padding:0}body{background:#323437;font-family:"Courier New",monospace;color:#d1d0c5;display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:100vh;padding:30px}h1{color:#e2b714;margin-bottom:24px;font-size:28px}.stats{display:flex;gap:40px;margin-bottom:20px;font-size:18px}.stat-label{color:#646669;font-size:12px;text-transform:uppercase}.stat-val{color:#e2b714;font-size:28px;font-weight:bold}#text-display{font-size:20px;line-height:1.8;max-width:700px;margin-bottom:20px;letter-spacing:1px}.correct{color:#e2b714}.wrong{color:#ca4754;text-decoration:underline}.current{background:#646669;border-radius:2px}#inp{opacity:0;position:absolute;pointer-events:none}#cursor{display:inline-block;width:2px;height:1em;background:#e2b714;animation:blink .7s infinite;vertical-align:text-bottom}@keyframes blink{0%,100%{opacity:1}50%{opacity:0}}.start-msg{color:#646669;font-size:16px;margin-bottom:10px}button{margin-top:16px;padding:10px 28px;background:#e2b714;color:#323437;border:none;border-radius:6px;font-size:16px;font-weight:bold;cursor:pointer}</style></head><body><h1>⌨ Typing Test</h1><div class="stats"><div><div class="stat-label">WPM</div><div class="stat-val" id="wpm">—</div></div><div><div class="stat-label">Accuracy</div><div class="stat-val" id="acc">—</div></div><div><div class="stat-label">Time</div><div class="stat-val" id="tm">60s</div></div></div><div class="start-msg" id="smsg">Click Start and begin typing</div><div id="text-display"></div><input id="inp" autofocus><button onclick="startTest()">Start</button><script>const TEXTS=["The quick brown fox jumps over the lazy dog near the riverbank on a warm summer afternoon.","Programming is the art of telling another human what one wants the computer to do in a clear and logical way.","Success is not final failure is not fatal it is the courage to continue that counts according to Churchill.","The only way to do great work is to love what you do if you have not found it yet keep looking and never settle."];let text,typed,pos,errors,startTime,timerInterval,running;function startTest(){clearInterval(timerInterval);text=TEXTS[Math.floor(Math.random()*TEXTS.length)];typed="";pos=0;errors=0;running=false;document.getElementById("smsg").textContent="Start typing...";document.getElementById("wpm").textContent="—";document.getElementById("acc").textContent="—";document.getElementById("tm").textContent="60s";renderText();document.getElementById("inp").value="";document.getElementById("inp").focus();document.getElementById("inp").addEventListener("input",onType)}function renderText(){let d=document.getElementById("text-display");let html="";for(let i=0;i<text.length;i++){let ch=text[i]==" "?"&nbsp;":text[i];if(i<pos){let isWrong=typed[i]&&typed[i]!==text[i];html+=`<span class="${isWrong?"wrong":"correct"}">${ch}</span>`}else if(i===pos){html+=`<span class="current">${ch}</span>`}else{html+=`<span>${ch}</span>`}}d.innerHTML=html}function onType(e){if(!running){running=true;startTime=Date.now();let t=60;timerInterval=setInterval(()=>{t--;document.getElementById("tm").textContent=t+"s";if(t<=0){clearInterval(timerInterval);finish()}},1000)}let val=document.getElementById("inp").value;if(val.length>pos){let ch=val[val.length-1];typed+=ch;if(ch!==text[pos])errors++;pos++}else if(val.length<pos){pos--;typed=typed.slice(0,-1)}renderText();if(pos>=text.length){clearInterval(timerInterval);finish()}}function finish(){running=false;let elapsed=(Date.now()-startTime)/1000;let words=pos/5;let wpm=Math.round(words/(elapsed/60));let acc=Math.round(((pos-errors)/pos)*100);document.getElementById("wpm").textContent=wpm;document.getElementById("acc").textContent=acc+"%";document.getElementById("smsg").textContent="Done! "+wpm+" WPM, "+acc+"% accuracy"}startTest();</script></body></html>	\N	\N
100	\N	Color Flood	Flood-fill the board from the top-left corner to make it all one color in fewest moves.	game	beginner	10	https://www.coolmathgames.com/	https://cdn.timewise.app/thumbs/game-color-flood.jpg	\N	t	en	31000	4.50	10	2026-03-21 00:46:13.125318+03	t	\N	<html><head><meta charset="UTF-8"><title>Color Flood</title><style>*{box-sizing:border-box;margin:0;padding:0}body{background:#111;font-family:Arial,sans-serif;color:#eee;display:flex;flex-direction:column;align-items:center;padding:20px;min-height:100vh}h1{margin-bottom:8px;color:#fff}.info{margin-bottom:10px;font-size:16px}#board{display:grid;gap:2px;margin-bottom:14px}.cell{width:28px;height:28px;border-radius:3px;transition:background .15s}.btns{display:flex;gap:8px;flex-wrap:wrap;justify-content:center;margin-bottom:10px}.color-btn{width:44px;height:44px;border:3px solid transparent;border-radius:8px;cursor:pointer;transition:border-color .15s}.color-btn:hover{border-color:#fff}.msg{font-size:16px;font-weight:bold;color:#0ff;min-height:22px}button.new{padding:8px 20px;background:#333;color:#fff;border:1px solid #555;border-radius:6px;cursor:pointer;margin-top:8px}</style></head><body><h1>🌊 Color Flood</h1><div class="info">Moves: <span id="mv">0</span> / 25</div><div id="board"></div><div class="btns" id="btns"></div><div class="msg" id="msg"></div><button class="new" onclick="init()">New Game</button><script>const COLS=14,ROWS=14,COLORS=["#e74c3c","#3498db","#2ecc71","#f39c12","#9b59b6","#1abc9c"];let grid,moves;function init(){grid=Array.from({length:ROWS},()=>Array.from({length:COLS},()=>Math.floor(Math.random()*COLORS.length)));moves=0;document.getElementById("mv").textContent=0;document.getElementById("msg").textContent="";render();renderBtns()}function render(){let b=document.getElementById("board");b.style.gridTemplateColumns=`repeat(${COLS},28px)`;b.innerHTML="";for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++){let d=document.createElement("div");d.className="cell";d.style.background=COLORS[grid[r][c]];b.appendChild(d)}}function renderBtns(){let b=document.getElementById("btns");b.innerHTML="";COLORS.forEach((col,i)=>{let btn=document.createElement("div");btn.className="color-btn";btn.style.background=col;btn.onclick=()=>flood(i);b.appendChild(btn)})}function flood(newC){let cur=grid[0][0];if(cur===newC)return;moves++;document.getElementById("mv").textContent=moves;let visited=Array.from({length:ROWS},()=>Array(COLS).fill(false));let q=[[0,0]];visited[0][0]=true;while(q.length){let[r,c]=q.shift();if(grid[r][c]===cur){grid[r][c]=newC;[[r-1,c],[r+1,c],[r,c-1],[r,c+1]].forEach(([nr,nc])=>{if(nr>=0&&nr<ROWS&&nc>=0&&nc<COLS&&!visited[nr][nc]){visited[nr][nc]=true;q.push([nr,nc])}})}}render();if(grid.flat().every(v=>v===newC))document.getElementById("msg").textContent="🎉 Cleared in "+moves+" moves!";else if(moves>=25)document.getElementById("msg").textContent="😢 Out of moves! Try again."}init();</script></body></html>	\N	\N
125	10	The Ottoman Empire: Rise, Golden Age and Fall	Six centuries of one of history's greatest empires — from Osman I to 1923.	video	beginner	22	https://www.youtube.com/watch?v=Ot2LM4QeKLI	https://cdn.timewise.app/thumbs/hist-ottoman.jpg	\N	t	en	2700000	4.80	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
126	10	Ancient Egypt: 3000 Years of Civilization	Pharaohs, pyramids, hieroglyphs and the Nile — the full civilizational story.	video	beginner	20	https://www.youtube.com/watch?v=bHPFV_1HKYA	https://cdn.timewise.app/thumbs/hist-egypt.jpg	\N	t	en	3900000	4.80	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
127	10	The Mongol Empire: Genghis Khan and the World's Largest Land Empire	From the steppes of Mongolia to the gates of Vienna — the most dramatic expansion in history.	video	beginner	18	https://www.youtube.com/watch?v=szxPar0BcMo	https://cdn.timewise.app/thumbs/hist-mongol.jpg	\N	t	en	3100000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
128	10	The Cold War: Complete History (1947–1991)	Forty-four years of nuclear tension, proxy wars and ideological rivalry.	video	intermediate	28	https://www.youtube.com/watch?v=wFpalMIABnA	https://cdn.timewise.app/thumbs/hist-coldwar-full.jpg	\N	t	en	2900000	4.90	30	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
129	10	The Renaissance: Art, Science and Humanism	How Italy reimagined antiquity and launched the modern world.	video	beginner	16	https://www.youtube.com/watch?v=Hd1IbyDMFyo	https://cdn.timewise.app/thumbs/hist-renaissance.jpg	\N	t	en	2400000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
101	\N	Math Sprint	Solve 20 arithmetic problems as fast as possible. Mental math trainer.	game	beginner	5	https://www.mathplayground.com/	https://cdn.timewise.app/thumbs/game-math-sprint.jpg	\N	t	en	38000	4.60	10	2026-03-21 00:46:13.125318+03	t	\N	<html><head><meta charset="UTF-8"><title>Math Sprint</title><style>*{box-sizing:border-box;margin:0;padding:0}body{background:#0a0a0a;font-family:Arial,sans-serif;color:#fff;display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:100vh;padding:20px}h1{color:#00e5ff;margin-bottom:20px}.problem{font-size:52px;font-weight:bold;margin-bottom:20px;letter-spacing:4px;color:#fff}.progress{font-size:14px;color:#555;margin-bottom:8px}input{font-size:32px;width:160px;text-align:center;padding:10px;background:#1a1a1a;border:2px solid #333;border-radius:8px;color:#fff;outline:none;margin-bottom:12px}input:focus{border-color:#00e5ff}.feedback{font-size:22px;min-height:30px;margin-bottom:10px}.stats{font-size:16px;color:#888;margin-bottom:20px}button{padding:10px 28px;background:#00e5ff;color:#000;border:none;border-radius:8px;font-size:16px;font-weight:bold;cursor:pointer}.timer{font-size:18px;color:#888;margin-bottom:6px}</style></head><body><h1>⚡ Math Sprint</h1><div class="progress" id="prog">Question 0/20</div><div class="problem" id="prob">—</div><div class="timer" id="tm"></div><input id="ans" type="number" placeholder="?" onkeydown="if(event.key==='Enter')submit()"><div class="feedback" id="fb"></div><div class="stats" id="stats"></div><button onclick="start()">Start</button><script>let qs,idx,correct,startTime,running;function randQ(){let ops=["+","-","×"];let op=ops[Math.floor(Math.random()*ops.length)];let a,b,ans;if(op==="+"){a=Math.floor(Math.random()*50)+1;b=Math.floor(Math.random()*50)+1;ans=a+b}else if(op==="-"){a=Math.floor(Math.random()*50)+10;b=Math.floor(Math.random()*a)+1;ans=a-b}else{a=Math.floor(Math.random()*12)+2;b=Math.floor(Math.random()*12)+2;ans=a*b}return{q:`${a} ${op} ${b}`,ans}}function start(){qs=Array.from({length:20},randQ);idx=0;correct=0;running=true;startTime=Date.now();document.getElementById("fb").textContent="";document.getElementById("stats").textContent="";document.getElementById("ans").value="";showQ()}function showQ(){if(idx>=20){finish();return}document.getElementById("prog").textContent=`Question ${idx+1}/20`;document.getElementById("prob").textContent=qs[idx].q+" = ?";document.getElementById("ans").value="";document.getElementById("ans").focus()}function submit(){if(!running)return;let v=parseInt(document.getElementById("ans").value);if(isNaN(v))return;if(v===qs[idx].ans){correct++;document.getElementById("fb").textContent="✅";document.getElementById("fb").style.color="#0f0"}else{document.getElementById("fb").textContent="❌ "+qs[idx].ans;document.getElementById("fb").style.color="#f44"}idx++;setTimeout(()=>{document.getElementById("fb").textContent="";showQ()},500)}function finish(){running=false;let t=((Date.now()-startTime)/1000).toFixed(1);let pct=Math.round(correct/20*100);document.getElementById("prob").textContent="Done!";document.getElementById("stats").textContent=`${correct}/20 correct • ${pct}% • ${t}s`}start();</script></body></html>	\N	\N
102	\N	Lo-Fi Hip Hop: Study & Focus Radio	24/7 lo-fi beats — gentle hip-hop rhythms proven to boost concentration.	music_playlist	beginner	60	https://www.youtube.com/watch?v=jfKfPfyJRdk	https://cdn.timewise.app/thumbs/playlist-lofi.jpg	\N	f	en	890000	4.90	20	2026-03-21 00:46:13.125318+03	t	\N	\N	https://www.youtube.com/watch?v=jfKfPfyJRdk	\N
103	\N	Deep Focus: Minimal Ambient Study Music	Instrumental ambient tracks — no lyrics, pure atmospheric focus.	music_playlist	beginner	90	https://www.youtube.com/watch?v=7NOSDKb0HlU	https://cdn.timewise.app/thumbs/playlist-ambient.jpg	\N	f	en	540000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	https://www.youtube.com/watch?v=7NOSDKb0HlU	\N
104	\N	Classical Music for Studying: Mozart & Bach	Timeless classical pieces — Mozart's Sonatas, Bach's Inventions and Beethoven's Bagatelles.	music_playlist	beginner	120	https://www.youtube.com/watch?v=Zi0BLhzxGKE	https://cdn.timewise.app/thumbs/playlist-classical.jpg	\N	f	en	720000	4.90	25	2026-03-21 00:46:13.125318+03	t	\N	\N	https://www.youtube.com/watch?v=Zi0BLhzxGKE	\N
105	\N	Jazz for Working: Coffee Shop Vibes	Smooth jazz instrumentals — perfect for creative tasks and relaxed focus.	music_playlist	beginner	90	https://www.youtube.com/watch?v=Dx5qFachd3A	https://cdn.timewise.app/thumbs/playlist-jazz.jpg	\N	f	en	430000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	https://www.youtube.com/watch?v=Dx5qFachd3A	\N
106	\N	Nature Sounds: Forest Rain for Relaxation	Rain, wind and birdsong — binaural nature soundscape for stress relief.	music_playlist	beginner	60	https://www.youtube.com/watch?v=xNN7iTA57jM	https://cdn.timewise.app/thumbs/playlist-nature.jpg	\N	f	en	380000	4.70	15	2026-03-21 00:46:13.125318+03	t	\N	\N	https://www.youtube.com/watch?v=xNN7iTA57jM	\N
107	\N	Binaural Beats: Alpha Waves for Creativity (10 Hz)	Alpha wave entrainment at 10 Hz — use with headphones for best effect.	music_playlist	beginner	60	https://www.youtube.com/watch?v=WPni755-Krg	https://cdn.timewise.app/thumbs/playlist-binaural.jpg	\N	f	en	290000	4.60	20	2026-03-21 00:46:13.125318+03	t	\N	\N	https://www.youtube.com/watch?v=WPni755-Krg	\N
108	\N	Epic Instrumental: Cinematic Study Music	Orchestral film scores without vocals — Hans Zimmer style, great for deep work.	music_playlist	beginner	120	https://www.youtube.com/watch?v=b_WRRQ4HNXU	https://cdn.timewise.app/thumbs/playlist-cinematic.jpg	\N	f	en	340000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	https://www.youtube.com/watch?v=b_WRRQ4HNXU	\N
109	\N	Piano Covers: Relaxing Game & Anime Music	Gentle solo piano arrangements of beloved game and anime soundtracks.	music_playlist	beginner	60	https://www.youtube.com/watch?v=tSFSFTMIfAI	https://cdn.timewise.app/thumbs/playlist-piano-covers.jpg	\N	f	en	260000	4.70	15	2026-03-21 00:46:13.125318+03	t	\N	\N	https://www.youtube.com/watch?v=tSFSFTMIfAI	\N
110	\N	30-Minute Yoga Flow Music	Calming instrumental music timed for a complete yoga or stretching session.	music_playlist	beginner	30	https://www.youtube.com/watch?v=M0u1MKPLNb0	https://cdn.timewise.app/thumbs/playlist-yoga.jpg	\N	f	en	210000	4.60	15	2026-03-21 00:46:13.125318+03	t	\N	\N	https://www.youtube.com/watch?v=M0u1MKPLNb0	\N
111	\N	Brown Noise for Deep Focus	Deep brown noise — blocks distractions and promotes sustained concentration.	music_playlist	beginner	180	https://www.youtube.com/watch?v=RqzGzwTY-6w	https://cdn.timewise.app/thumbs/playlist-brown-noise.jpg	\N	f	en	195000	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	https://www.youtube.com/watch?v=RqzGzwTY-6w	\N
112	\N	The Social Dilemma (Full Film)	Former tech insiders reveal how social media is designed to manipulate attention and behavior.	documentary	beginner	94	https://www.youtube.com/watch?v=uaaC57tcci0	https://cdn.timewise.app/thumbs/doc-social-dilemma.jpg	\N	f	en	4200000	4.80	50	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
113	\N	Abstract: The Art of Design — Christoph Niemann	Netflix documentary episode on illustration and creative process — free on YouTube.	documentary	beginner	44	https://www.youtube.com/watch?v=4bBDdoMGS5k	https://cdn.timewise.app/thumbs/doc-abstract.jpg	\N	f	en	1800000	4.70	35	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
114	\N	Inside Bill's Brain: Decoding Bill Gates (Ep. 1)	How Bill Gates approaches the world's toughest problems — energy, water, disease.	documentary	beginner	60	https://www.youtube.com/watch?v=aCv29JKmHNY	https://cdn.timewise.app/thumbs/doc-bill-gates.jpg	\N	f	en	2900000	4.60	40	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
115	\N	Cosmos: A Spacetime Odyssey — Ep. 1	Neil deGrasse Tyson's acclaimed series. Episode 1: Standing Up in the Milky Way.	documentary	beginner	43	https://www.youtube.com/watch?v=MBRqu0YOH14	https://cdn.timewise.app/thumbs/doc-cosmos.jpg	\N	f	en	3600000	4.90	35	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
116	\N	13th — Race, Mass Incarceration and the US Constitution	Ava DuVernay's Oscar-nominated documentary exploring systemic inequality.	documentary	intermediate	100	https://www.youtube.com/watch?v=krfcq5pF8u8	https://cdn.timewise.app/thumbs/doc-13th.jpg	\N	f	en	5100000	4.80	55	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
117	\N	AlphaGo — The Movie	The story of Google DeepMind's AI defeating the world Go champion. Gripping.	documentary	beginner	90	https://www.youtube.com/watch?v=WXuK6gekU1Y	https://cdn.timewise.app/thumbs/doc-alphago.jpg	\N	f	en	3300000	4.90	50	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
118	\N	Free Solo	Oscar-winning film about Alex Honnold climbing El Capitan with no ropes.	documentary	beginner	100	https://www.youtube.com/watch?v=urRVZ4SW7WU	https://cdn.timewise.app/thumbs/doc-free-solo.jpg	\N	f	en	2700000	4.90	55	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
119	\N	Minimalism: A Documentary About the Important Things	Two men explore how to live a meaningful life with less stuff.	documentary	beginner	78	https://www.youtube.com/watch?v=0Co1Iptd4p4	https://cdn.timewise.app/thumbs/doc-minimalism.jpg	\N	f	en	1900000	4.60	45	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
120	\N	The True Cost — Fast Fashion Documentary	The human and environmental price of cheap clothing. Eye-opening.	documentary	beginner	92	https://www.youtube.com/watch?v=OaGp5_Sfbss	https://cdn.timewise.app/thumbs/doc-true-cost.jpg	\N	f	en	2400000	4.70	50	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
130	10	The History of the United States in 10 Minutes	Colonies to superpower — the key turning points condensed.	video	beginner	10	https://www.youtube.com/watch?v=fSuCkqYHN_Y	https://cdn.timewise.app/thumbs/hist-usa.jpg	\N	t	en	4700000	4.60	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
131	10	Alexander the Great: Conqueror of the Ancient World	Thirteen years, three continents, one general who never lost a battle.	video	beginner	15	https://www.youtube.com/watch?v=h6_vBLEAEzA	https://cdn.timewise.app/thumbs/hist-alexander.jpg	\N	t	en	2200000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
132	10	Napoleon Bonaparte: Rise and Fall	From Corsican soldier to Emperor of Europe — and back again.	video	beginner	20	https://www.youtube.com/watch?v=O2sP_DDPGIY	https://cdn.timewise.app/thumbs/hist-napoleon.jpg	\N	t	en	3300000	4.80	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
133	10	The Industrial Revolution: How It Changed Everything	Steam, factories and urbanisation — the shift that defines modernity.	video	beginner	14	https://www.youtube.com/watch?v=zjBNIb6aq8E	https://cdn.timewise.app/thumbs/hist-industrial.jpg	\N	t	en	2800000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
134	10	Marie Curie: A Pioneering Life	The first woman to win a Nobel Prize — twice. A biography of perseverance.	video	beginner	12	https://www.youtube.com/watch?v=w6JFRi0Qm_s	https://cdn.timewise.app/thumbs/hist-curie.jpg	\N	t	en	1900000	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
135	10	Nelson Mandela: Long Walk to Freedom	From Robben Island prisoner to the first democratically elected President of South Africa.	video	beginner	15	https://www.youtube.com/watch?v=j7ZNpFtgD8Q	https://cdn.timewise.app/thumbs/hist-mandela.jpg	\N	t	en	2100000	4.90	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
136	10	Cleopatra: The Last Pharaoh	Power, diplomacy and survival — the real story behind the legend.	video	beginner	12	https://www.youtube.com/watch?v=_2KJQ35dtuk	https://cdn.timewise.app/thumbs/hist-cleopatra.jpg	\N	t	en	1800000	4.70	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
137	10	The History of Writing: From Cuneiform to the Alphabet	How humans developed the technology of writing over 5000 years.	video	beginner	10	https://www.youtube.com/watch?v=wY2nKQ0n5aI	https://cdn.timewise.app/thumbs/hist-writing.jpg	\N	t	en	1600000	4.70	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
138	10	The Byzantine Empire: The Eastern Rome That Survived 1000 Years	Constantinople, Orthodox Christianity and the empire the West forgot.	video	beginner	18	https://www.youtube.com/watch?v=rNNkF_eqAV4	https://cdn.timewise.app/thumbs/hist-byzantine.jpg	\N	t	en	2000000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
139	10	The Silk Road: Trade, Ideas and Empires	How the ancient trade network connected China to Rome and spread religions, plagues and inventions.	video	beginner	14	https://www.youtube.com/watch?v=vouE4a-s4lA	https://cdn.timewise.app/thumbs/hist-silk-road.jpg	\N	t	en	1700000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
140	10	The History of Pandemics: From Plague to COVID	Black Death, Spanish Flu, HIV, COVID-19 — how humanity has faced and survived disease.	video	beginner	16	https://www.youtube.com/watch?v=iFLSG-7K3Tc	https://cdn.timewise.app/thumbs/hist-pandemics.jpg	\N	t	en	2500000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
141	10	Nikola Tesla: The Forgotten Genius	AC electricity, radio, the Tesla coil — and why Edison won the PR war.	video	beginner	12	https://www.youtube.com/watch?v=hGNWsHMmGR4	https://cdn.timewise.app/thumbs/hist-tesla.jpg	\N	t	en	3100000	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
142	10	How to Look at a Painting: Art Appreciation 101	Composition, colour theory, symbolism — tools to decode any artwork.	video	beginner	14	https://www.youtube.com/watch?v=SqOMxELgL_0	https://cdn.timewise.app/thumbs/cult-painting.jpg	\N	t	en	1400000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
143	10	The History of Cinema: From Lumière to Streaming	Silent films, the studio system, French New Wave, blockbusters and Netflix.	video	beginner	18	https://www.youtube.com/watch?v=7nIIcBRnvYY	https://cdn.timewise.app/thumbs/cult-cinema.jpg	\N	t	en	1200000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
144	10	Greek Mythology: Gods, Heroes and Monsters	Zeus, Odysseus, the Minotaur — the complete world of ancient Greek myth.	video	beginner	20	https://www.youtube.com/watch?v=qvQ9CJnGfNA	https://cdn.timewise.app/thumbs/cult-greek-myth.jpg	\N	t	en	3800000	4.80	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
145	10	Shakespeare: Life, Works and Why He Still Matters	The bard's biography, major plays and the enduring influence on language.	video	beginner	15	https://www.youtube.com/watch?v=VBjoSHSyxVs	https://cdn.timewise.app/thumbs/cult-shakespeare.jpg	\N	t	en	1500000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
146	10	Architecture Through the Ages: From Parthenon to Zaha Hadid	Doric, Gothic, Baroque, Modernism, Parametric — how buildings reflect their era.	video	beginner	16	https://www.youtube.com/watch?v=fRlWFHYU-jM	https://cdn.timewise.app/thumbs/cult-architecture.jpg	\N	t	en	1100000	4.60	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
147	10	The Origins of Language: How Humans Started Talking	Proto-language, language families and the mystery of the first words.	video	intermediate	14	https://www.youtube.com/watch?v=I2ZAl-kIlFk	https://cdn.timewise.app/thumbs/cult-language-origins.jpg	\N	t	en	980000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
148	10	The History of Music: A 30-Minute Journey	From ancient instruments to Bach, jazz, rock and electronic music.	video	beginner	30	https://www.youtube.com/watch?v=OcHmW9mkTUo	https://cdn.timewise.app/thumbs/cult-music-history.jpg	\N	t	en	2100000	4.80	30	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
149	10	The Psychology of Colour in Art and Design	How colour choices shape emotion, perception and cultural meaning.	video	beginner	12	https://www.youtube.com/watch?v=x0-O6kBpCQA	https://cdn.timewise.app/thumbs/cult-colour.jpg	\N	t	en	870000	4.60	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
150	10	Literary Movements: Romanticism to Postmodernism	The intellectual currents that shaped the novels and poems you know.	video	intermediate	18	https://www.youtube.com/watch?v=fTTDOtgXL_k	https://cdn.timewise.app/thumbs/cult-literary.jpg	\N	t	en	760000	4.60	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
151	10	Street Art and Graffiti: From Crime to Canvas	Banksy, Basquiat, Jean-Michel and how urban art entered the gallery.	video	beginner	14	https://www.youtube.com/watch?v=O5DUBnJiHUk	https://cdn.timewise.app/thumbs/cult-street-art.jpg	\N	t	en	920000	4.60	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
152	10	The History of Fashion: From Ancient Textiles to Fast Fashion	Corsets, Chanel, punk, streetwear — how clothing has signalled identity.	video	beginner	20	https://www.youtube.com/watch?v=PTsQoIHqiF8	https://cdn.timewise.app/thumbs/cult-fashion-hist.jpg	\N	t	en	1300000	4.60	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
153	10	The Harlem Renaissance: Black Art, Music and Literature in the 1920s	Langston Hughes, Louis Armstrong and the cultural explosion that changed America.	video	beginner	12	https://www.youtube.com/watch?v=0M2OWJhfCp8	https://cdn.timewise.app/thumbs/cult-harlem.jpg	\N	t	en	1050000	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
154	10	How Fonts Shape Our Perception	Typography, readability and the psychology behind typeface choices.	video	beginner	10	https://www.youtube.com/watch?v=eZSe4xVXHhI	https://cdn.timewise.app/thumbs/cult-fonts.jpg	\N	t	en	1700000	4.70	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
155	10	Japanese Aesthetics: Wabi-Sabi, Ma and Ikigai	Three Japanese concepts that offer a radically different way to see beauty and purpose.	video	beginner	14	https://www.youtube.com/watch?v=QmHLYhxYVjA	https://cdn.timewise.app/thumbs/cult-japanese.jpg	\N	t	en	1600000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
156	10	Mythology Compared: Greek vs Norse vs Hindu	Creation myths, pantheons, cosmologies — what different cultures imagined.	video	beginner	18	https://www.youtube.com/watch?v=8iSfNJx-hAI	https://cdn.timewise.app/thumbs/cult-mythology.jpg	\N	t	en	1900000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
157	1	How Computers Work: CPU, Memory and the Von Neumann Architecture	Transistors, logic gates, ALU, RAM and the fetch-decode-execute cycle.	video	beginner	15	https://www.youtube.com/watch?v=zltgXvg6r3k	https://cdn.timewise.app/thumbs/tech-computer-arch.jpg	\N	t	en	2800000	4.90	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
158	1	Algorithms Explained: Big O, Sorting and Search	Time complexity, O(n log n) sorting and binary search — no maths degree needed.	video	intermediate	20	https://www.youtube.com/watch?v=47GRtdHOKMg	https://cdn.timewise.app/thumbs/tech-algorithms.jpg	\N	t	en	2100000	4.80	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
159	1	How the Web Works: DNS, HTTP, TCP/IP Deep Dive	What happens between pressing Enter and seeing a webpage.	video	intermediate	18	https://www.youtube.com/watch?v=zN8YNNHcaZc	https://cdn.timewise.app/thumbs/tech-web-deep.jpg	\N	t	en	1900000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
160	1	Operating Systems: Processes, Threads and Scheduling	How your OS manages multiple programs at once — context switching and scheduling.	video	intermediate	22	https://www.youtube.com/watch?v=7vUs5yOuv-o	https://cdn.timewise.app/thumbs/tech-os.jpg	\N	t	en	1500000	4.70	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
161	1	Databases: SQL vs NoSQL — When to Use Each	Relational vs document vs graph databases — tradeoffs explained.	video	beginner	16	https://www.youtube.com/watch?v=t8U3MQgMpbk	https://cdn.timewise.app/thumbs/tech-db.jpg	\N	t	en	1800000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
162	1	How Git Works Under the Hood	Objects, blobs, trees, commits and refs — what git actually stores.	video	intermediate	20	https://www.youtube.com/watch?v=lG90LZotrpo	https://cdn.timewise.app/thumbs/tech-git-internals.jpg	\N	t	en	1200000	4.80	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
163	1	Cryptography: How HTTPS Keeps You Safe	Symmetric vs asymmetric encryption, TLS handshake and certificates.	video	intermediate	18	https://www.youtube.com/watch?v=AQDCe585Lnc	https://cdn.timewise.app/thumbs/tech-crypto.jpg	\N	t	en	2200000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
164	1	Docker and Containers Explained in 15 Minutes	What containers are, why they matter and how Docker works.	video	beginner	15	https://www.youtube.com/watch?v=pTFZFxd5hgI	https://cdn.timewise.app/thumbs/tech-docker.jpg	\N	t	en	2600000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
165	1	How Neural Networks Learn: Backpropagation Visualised	Weights, gradients and the chain rule — the maths behind deep learning made visual.	video	intermediate	20	https://www.youtube.com/watch?v=Ilg3gGewQ5U	https://cdn.timewise.app/thumbs/tech-neural.jpg	\N	t	en	3100000	4.90	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
166	1	Linux Command Line: 20 Commands Every Developer Should Know	cd, ls, grep, awk, curl, chmod and piping — practical shell survival kit.	tutorial	beginner	20	https://www.youtube.com/watch?v=ZtqBQ68cfJc	https://cdn.timewise.app/thumbs/tech-linux.jpg	\N	t	en	1700000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
167	1	Design Patterns: The Big 3 — Singleton, Observer, Factory	The most important GoF patterns with real-world analogies.	video	intermediate	18	https://www.youtube.com/watch?v=tv-_1er1mWI	https://cdn.timewise.app/thumbs/tech-patterns.jpg	\N	t	en	1400000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
168	1	Recursion Explained: How Functions Call Themselves	Stack frames, base cases and elegant solutions to complex problems.	video	intermediate	14	https://www.youtube.com/watch?v=IJDJ0kBx2LM	https://cdn.timewise.app/thumbs/tech-recursion.jpg	\N	t	en	1900000	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
169	1	How the Internet Was Invented: ARPANET to WWW	Packet switching, TCP/IP and Tim Berners-Lee's world-changing idea.	video	beginner	14	https://www.youtube.com/watch?v=9hIQjrMHTv4	https://cdn.timewise.app/thumbs/tech-internet-history.jpg	\N	t	en	2400000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
170	1	Web Accessibility: Why and How to Build for Everyone	WCAG guidelines, screen readers and semantic HTML — building inclusive products.	article	intermediate	12	https://web.dev/accessibility/	https://cdn.timewise.app/thumbs/tech-a11y.jpg	\N	t	en	890000	4.70	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
171	1	The History of Programming Languages: FORTRAN to Python	Assembly, C, Smalltalk, Java, Python — why each language emerged when it did.	video	beginner	18	https://www.youtube.com/watch?v=Tr9E_vzKRVo	https://cdn.timewise.app/thumbs/tech-lang-history.jpg	\N	t	en	1600000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
172	10	How Evolution Works: Natural Selection Explained	Mutation, selection pressure, adaptation and speciation — Darwin decoded.	video	beginner	14	https://www.youtube.com/watch?v=GhHOjC4oxh8	https://cdn.timewise.app/thumbs/sci-evolution.jpg	\N	t	en	3700000	4.90	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
173	10	Quantum Mechanics for Curious People	Wave-particle duality, superposition and Schrödinger's cat — without the equations.	video	beginner	16	https://www.youtube.com/watch?v=7u_UQG1La1o	https://cdn.timewise.app/thumbs/sci-quantum.jpg	\N	t	en	4200000	4.90	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
174	10	The Human Cell: How Life Works at the Microscopic Level	DNA replication, protein synthesis and cell division — the machinery of life.	video	beginner	15	https://www.youtube.com/watch?v=URUJD5NEXC8	https://cdn.timewise.app/thumbs/sci-cell.jpg	\N	t	en	2900000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
175	10	Black Holes: From Theory to the First Image	Singularities, event horizons, Hawking radiation and the EHT photograph.	video	beginner	18	https://www.youtube.com/watch?v=e-P5IFTqB98	https://cdn.timewise.app/thumbs/sci-blackhole.jpg	\N	t	en	5100000	4.90	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
176	10	Climate Science: What We Know and Why It Matters	Greenhouse effect, feedback loops and the evidence for human-caused warming.	video	beginner	16	https://www.youtube.com/watch?v=ifrHogDujXw	https://cdn.timewise.app/thumbs/sci-climate.jpg	\N	t	en	3300000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
177	10	The Periodic Table: Why Elements Are Arranged That Way	Atomic structure, valence electrons and why Mendeleev's grid is a work of genius.	video	beginner	12	https://www.youtube.com/watch?v=0RRVV4Diomg	https://cdn.timewise.app/thumbs/sci-periodic.jpg	\N	t	en	2100000	4.70	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
178	10	CRISPR: The Gene Editing Revolution	How scientists can now edit the code of life — and the ethical questions it raises.	video	beginner	14	https://www.youtube.com/watch?v=jAhjPd4uNFY	https://cdn.timewise.app/thumbs/sci-crispr.jpg	\N	t	en	3800000	4.90	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
179	10	How Vaccines Work: The Immune System Explained	Antigens, antibodies, B-cells and the mechanism behind herd immunity.	video	beginner	12	https://www.youtube.com/watch?v=rbfOoshNeW4	https://cdn.timewise.app/thumbs/sci-vaccines.jpg	\N	t	en	4600000	4.90	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
180	10	The Standard Model of Particle Physics	Quarks, leptons, bosons and the Higgs field — the deepest description of matter.	video	intermediate	18	https://www.youtube.com/watch?v=ehHoOYqAT_U	https://cdn.timewise.app/thumbs/sci-standard-model.jpg	\N	t	en	2500000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
181	10	The Science of Sleep: Why We Dream	Sleep cycles, REM, memory consolidation and why dreams exist.	video	beginner	14	https://www.youtube.com/watch?v=2W85Dwxx218	https://cdn.timewise.app/thumbs/sci-sleep.jpg	\N	t	en	3900000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
182	10	The Fall of Constantinople 1453	How Mehmed II ended the Byzantine Empire — siege tactics, geography and legacy.	video	beginner	15	https://www.youtube.com/watch?v=DPHlFGFGBgw	https://cdn.timewise.app/thumbs/hist-constantinople.jpg	\N	t	en	4100000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
183	10	The French Revolution: Causes, Events and Legacy	From Estates-General to Napoleon — the revolution that reshaped modern politics.	video	beginner	20	https://www.youtube.com/watch?v=5fJl_ZX91l0	https://cdn.timewise.app/thumbs/hist-french-rev.jpg	\N	t	en	3800000	4.80	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
184	10	World War I: The War That Changed Everything	Causes, major fronts, and why WWI produced the 20th century we know.	video	beginner	20	https://www.youtube.com/watch?v=dHSQAEam2yc	https://cdn.timewise.app/thumbs/hist-ww1.jpg	\N	t	en	6200000	4.90	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
185	10	The Silk Road: Trade, Ideas and Plague	How the ancient network linking China to Rome spread goods, religions and disease.	video	beginner	12	https://www.youtube.com/watch?v=jNEGPRSdEyQ	https://cdn.timewise.app/thumbs/hist-silkroad.jpg	\N	t	en	2900000	4.70	18	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
186	10	The Mongol Empire: How One Man Conquered Half the World	Genghis Khan's rise, the Pax Mongolica, and the empire's sudden collapse.	video	beginner	18	https://www.youtube.com/watch?v=m2kFNq1L9UM	https://cdn.timewise.app/thumbs/hist-mongol.jpg	\N	t	en	5100000	4.80	22	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
187	10	The Black Death: How the Plague Changed Medieval Europe	Demographics, religion, medicine and the social upheaval of the 14th-century pandemic.	video	beginner	14	https://www.youtube.com/watch?v=Dj_p3vCyOFE	https://cdn.timewise.app/thumbs/hist-blackdeath.jpg	\N	t	en	3600000	4.70	18	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
188	10	The Space Race: From Sputnik to the Moon	Cold War competition that put humans on the Moon — politics, engineering and heroism.	video	beginner	18	https://www.youtube.com/watch?v=NIWCsH9u5A0	https://cdn.timewise.app/thumbs/hist-spacerace.jpg	\N	t	en	4400000	4.90	22	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
189	10	The Industrial Revolution: How It Remade the World	Steam power, factory labour, urbanisation — and the environmental consequences that followed.	video	beginner	16	https://www.youtube.com/watch?v=zhL5DCizj5c	https://cdn.timewise.app/thumbs/hist-industrial.jpg	\N	t	en	3200000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
190	10	Ancient Egypt: Gods, Pharaohs and the Afterlife	Hieroglyphs, the pyramid builders, mummification and the pantheon explained.	video	beginner	20	https://www.youtube.com/watch?v=hO68A3bCOow	https://cdn.timewise.app/thumbs/hist-egypt.jpg	\N	t	en	5500000	4.80	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
191	10	The Ottoman Empire: Rise, Zenith and Decline	600 years from Osman I to Atatürk — an empire that spanned three continents.	video	beginner	22	https://www.youtube.com/watch?v=sPLFxMZHQaM	https://cdn.timewise.app/thumbs/hist-ottoman.jpg	\N	t	en	4700000	4.90	28	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
192	10	The Renaissance: How Art and Science Were Reborn	Florence, patronage, Leonardo, Michelangelo — why the 15th century still matters.	video	beginner	15	https://www.youtube.com/watch?v=Hd1gF7bJenU	https://cdn.timewise.app/thumbs/hist-renaissance.jpg	\N	t	en	3300000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
193	10	The Cold War: Full Documentary	Proxy wars, nuclear standoffs and ideological competition from 1947 to 1991.	documentary	intermediate	55	https://www.youtube.com/watch?v=wqwKn_UtDPA	https://cdn.timewise.app/thumbs/hist-coldwar-full.jpg	\N	f	en	2800000	4.70	40	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
194	10	The Atlantic Slave Trade: History, Impact and Memory	The mechanics, scale, survivors and lasting effects of the transatlantic slave system.	video	beginner	17	https://www.youtube.com/watch?v=dnV0NkFi3F0	https://cdn.timewise.app/thumbs/hist-slave-trade.jpg	\N	f	en	6900000	4.90	22	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
195	10	The Age of Exploration: Columbus, Magellan and Their World	What drove European expansion, who financed it, and what it cost indigenous peoples.	video	beginner	15	https://www.youtube.com/watch?v=Q5aEjxI9i_I	https://cdn.timewise.app/thumbs/hist-exploration.jpg	\N	t	en	2700000	4.60	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
196	10	Alexander the Great: Conqueror of the Known World	Macedonia to India in 13 years — strategy, charisma and the Hellenistic legacy.	video	beginner	16	https://www.youtube.com/watch?v=NaFGJJxHHZY	https://cdn.timewise.app/thumbs/hist-alexander.jpg	\N	t	en	4100000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
197	10	The Weimar Republic and the Rise of Hitler	Economic collapse, political extremism and the democratic failure of the 1920s.	video	intermediate	18	https://www.youtube.com/watch?v=mhx-228miBc	https://cdn.timewise.app/thumbs/hist-weimar.jpg	\N	t	en	3500000	4.80	22	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
198	10	The Story of India: 3000 Years in 20 Minutes	Indus Valley to Mughal Empire to independence — the sweep of Indian civilisation.	video	beginner	20	https://www.youtube.com/watch?v=GXsXzQ8VPm8	https://cdn.timewise.app/thumbs/hist-india.jpg	\N	t	en	3100000	4.70	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
199	10	World War II: Causes, Major Events, Outcome	From Versailles to Hiroshima — the deadliest conflict in human history explained.	video	beginner	25	https://www.youtube.com/watch?v=fo2Rb9h788s	https://cdn.timewise.app/thumbs/hist-ww2.jpg	\N	t	en	8200000	4.90	30	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
200	10	Ancient Rome: Republic to Empire	SPQR, Julius Caesar, Augustus — how a city-state became the ancient world's superpower.	video	beginner	18	https://www.youtube.com/watch?v=PoNHSBsLMKE	https://cdn.timewise.app/thumbs/hist-rome-empire.jpg	\N	t	en	5600000	4.90	22	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
201	10	The Cuban Missile Crisis: 13 Days That Nearly Ended the World	October 1962 — secret transcripts, back-channel diplomacy, and the luck that saved us.	video	beginner	14	https://www.youtube.com/watch?v=bwWW3sbk4EU	https://cdn.timewise.app/thumbs/hist-cuban-crisis.jpg	\N	t	en	3800000	4.90	18	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
202	10	How Movies Are Made: A Crash Course in Filmmaking	Pre-production to post — script, shot lists, editing and colour grading explained.	video	beginner	18	https://www.youtube.com/watch?v=LKe5B1cF_5k	https://cdn.timewise.app/thumbs/cult-filmmaking.jpg	\N	t	en	2400000	4.70	22	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
203	10	A Brief History of Western Art: Cave Paintings to Warhol	20,000 years of visual art in 20 minutes — movements, masterpieces and meaning.	video	beginner	20	https://www.youtube.com/watch?v=mUCfXBXBhVA	https://cdn.timewise.app/thumbs/cult-art-history.jpg	\N	t	en	3300000	4.80	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
204	10	How Great Architecture Works: 10 Buildings Explained	Pantheon, Sagrada Família, Guggenheim Bilbao — what makes a building iconic.	video	beginner	16	https://www.youtube.com/watch?v=hmHiEPLjL_k	https://cdn.timewise.app/thumbs/cult-architecture.jpg	\N	t	en	2100000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
205	10	The History of Photography: Daguerreotype to Digital	From the first fixed image in 1826 to Instagram — art, science and society.	video	beginner	14	https://www.youtube.com/watch?v=cKn0sXoLdss	https://cdn.timewise.app/thumbs/cult-photography.jpg	\N	t	en	1800000	4.60	18	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
206	10	How Jazz Changed American Music Forever	New Orleans, bebop, Miles Davis and the ongoing revolution of improvisation.	video	beginner	15	https://www.youtube.com/watch?v=GlBP_qs6HLc	https://cdn.timewise.app/thumbs/cult-jazz-history.jpg	\N	t	en	2600000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
207	10	Literary Movements: Romanticism to Postmodernism	The major schools of Western literature — what they reacted against and why they mattered.	article	intermediate	20	https://www.youtube.com/watch?v=M3FLKGu_X2Y	https://cdn.timewise.app/thumbs/cult-literary.jpg	\N	t	en	1500000	4.60	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
208	10	The Harlem Renaissance: Art, Music and Black Identity	How the 1920s Harlem movement transformed American culture.	video	beginner	14	https://www.youtube.com/watch?v=SCZO-phbxAk	https://cdn.timewise.app/thumbs/cult-harlem.jpg	\N	t	en	2200000	4.80	18	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
209	10	How Theatre Works: A Short History of Performance	Ancient Greece to Broadway — drama, tragedy, comedy and the body as instrument.	video	beginner	15	https://www.youtube.com/watch?v=4Fso3dBhgEE	https://cdn.timewise.app/thumbs/cult-theatre.jpg	\N	t	en	1700000	4.60	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
210	10	The Birth of Cinema: Lumière to Hitchcock	Silent films, the talkies, Hollywood's golden age and the directors who defined them.	video	beginner	17	https://www.youtube.com/watch?v=0wjEw0HfXNk	https://cdn.timewise.app/thumbs/cult-cinema-history.jpg	\N	t	en	1900000	4.70	22	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
211	10	How Shakespeare's Language Still Shapes English	Over 1,700 words Shakespeare invented and why his metaphors live in daily speech.	article	beginner	12	https://www.youtube.com/watch?v=OGqCMF9mBrY	https://cdn.timewise.app/thumbs/cult-shakespeare.jpg	\N	t	en	2800000	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
212	10	The History of the Internet: ARPANET to TikTok	From 1969 packet-switching to social media dominance — the 50-year story.	video	beginner	18	https://www.youtube.com/watch?v=9hIQjrMHTv4	https://cdn.timewise.app/thumbs/cult-internet-hist.jpg	\N	t	en	3100000	4.80	22	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
213	10	Street Art and Graffiti: Vandalism to Global Art Form	Banksy, Basquiat, 5Pointz — how illegal spray paint became gallery-worthy.	video	beginner	13	https://www.youtube.com/watch?v=EpHX6c8BifU	https://cdn.timewise.app/thumbs/cult-street-art.jpg	\N	t	en	1600000	4.60	18	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
214	10	The Philosophy of Music: Why Do Songs Make Us Cry?	Acoustics, emotion, memory and the neuroscience behind musical experience.	video	intermediate	16	https://www.youtube.com/watch?v=DCFbFdl_FM4	https://cdn.timewise.app/thumbs/cult-music-philosophy.jpg	\N	t	en	2000000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
215	10	Fashion History: How Clothing Became Identity	From ancient textiles to Chanel to streetwear — clothes as power and resistance.	video	beginner	14	https://www.youtube.com/watch?v=Q0UEUMXK7aY	https://cdn.timewise.app/thumbs/cult-fashion-hist.jpg	\N	t	en	1800000	4.50	18	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
216	10	Mythology Explained: Greek, Norse and Mesopotamian	Creation myths, hero cycles and monster stories across three great traditions.	video	beginner	22	https://www.youtube.com/watch?v=7gaBUMBFKpo	https://cdn.timewise.app/thumbs/cult-mythology.jpg	\N	t	en	4200000	4.90	28	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
217	1	How Operating Systems Work: The Hidden Layer	Processes, memory management, file systems and the kernel — no code required.	article	beginner	14	https://www.youtube.com/watch?v=26QPDBe-NB8	https://cdn.timewise.app/thumbs/tech-os.jpg	\N	t	en	2100000	4.70	18	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
218	1	Algorithms Explained: Sorting, Searching, Complexity	Big-O notation, merge sort, binary search — the foundation of computer science.	video	intermediate	20	https://www.youtube.com/watch?v=kPRA0W1kECg	https://cdn.timewise.app/thumbs/tech-algorithms.jpg	\N	t	en	3800000	4.90	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
219	1	How Databases Work: SQL vs NoSQL Explained	ACID, indexing, joins and when to choose Postgres vs MongoDB.	video	beginner	16	https://www.youtube.com/watch?v=W2Z7fbCLSTw	https://cdn.timewise.app/thumbs/tech-databases.jpg	\N	t	en	2600000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
220	1	Computer Networks: How the Web Really Works	IP, DNS, TCP, HTTP/2, TLS — every layer of the stack from your browser to the server.	video	intermediate	18	https://www.youtube.com/watch?v=3QhU9jd03a0	https://cdn.timewise.app/thumbs/tech-networks.jpg	\N	t	en	2400000	4.80	22	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
221	1	The History of Programming Languages	FORTRAN to Python — why languages were invented, who used them and what survived.	video	beginner	18	https://www.youtube.com/watch?v=Tr9E_vzKRVo	https://cdn.timewise.app/thumbs/tech-lang-history.jpg	\N	t	en	3100000	4.80	22	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
222	1	How Cryptography Works: From Caesar Cipher to AES	Symmetric vs asymmetric keys, hash functions and how HTTPS protects you.	video	intermediate	20	https://www.youtube.com/watch?v=AQDCe585Lnc	https://cdn.timewise.app/thumbs/tech-cryptography.jpg	\N	t	en	3500000	4.90	25	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
223	1	Docker in 100 Seconds — Containers Explained	Why containers exist, how they differ from VMs, and the core Docker workflow.	video	beginner	8	https://www.youtube.com/watch?v=Gjnup-PuquQ	https://cdn.timewise.app/thumbs/tech-docker.jpg	\N	t	en	4200000	4.90	12	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
224	1	How GPUs Accelerate AI: From Gaming to Deep Learning	Why parallel compute matters, CUDA cores and the architecture behind ChatGPT's training.	article	intermediate	16	https://www.youtube.com/watch?v=r5NQecwZs1A	https://cdn.timewise.app/thumbs/tech-gpu.jpg	\N	t	en	2900000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
225	1	Big O Notation: A Visual Guide	O(1), O(n), O(log n) and O(n²) — what they mean and how to spot them in code.	video	beginner	12	https://www.youtube.com/watch?v=v4cd1O4zkGw	https://cdn.timewise.app/thumbs/tech-bigo.jpg	\N	t	en	3700000	4.90	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
226	1	Object-Oriented Programming: The Four Pillars	Encapsulation, inheritance, polymorphism, abstraction — with real-world analogies.	video	beginner	14	https://www.youtube.com/watch?v=pTB0EiLXUC8	https://cdn.timewise.app/thumbs/tech-oop.jpg	\N	t	en	2800000	4.80	18	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
227	1	How Neural Networks Work: A Visual Explanation	Perceptrons, layers, backpropagation and gradient descent — no maths required.	video	intermediate	18	https://www.youtube.com/watch?v=aircAruvnKk	https://cdn.timewise.app/thumbs/tech-neural-net.jpg	\N	t	en	5100000	4.90	22	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
228	1	Web Security 101: OWASP Top 10 Explained	SQL injection, XSS, CSRF and the ten most dangerous web vulnerabilities.	article	intermediate	16	https://www.youtube.com/watch?v=rWHvp7rUka8	https://cdn.timewise.app/thumbs/tech-security.jpg	\N	t	en	2300000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
229	1	Functional Programming: Why It Matters	Pure functions, immutability, higher-order functions — and why they reduce bugs.	video	intermediate	15	https://www.youtube.com/watch?v=e-5obm1G_FY	https://cdn.timewise.app/thumbs/tech-functional.jpg	\N	t	en	2600000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
230	1	How the Cloud Works: AWS, Azure and GCP Explained	IaaS, PaaS, SaaS, regions, availability zones — cloud concepts without the jargon.	video	beginner	16	https://www.youtube.com/watch?v=M988_fsOSWo	https://cdn.timewise.app/thumbs/tech-cloud.jpg	\N	t	en	3200000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
231	1	Linux Command Line Basics in 15 Minutes	cd, ls, grep, pipe, chmod, ssh — the essential commands every developer needs.	tutorial	beginner	15	https://www.youtube.com/watch?v=ZtqBQ68cfJc	https://cdn.timewise.app/thumbs/tech-linux.jpg	\N	t	en	4600000	4.90	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
232	10	Quantum Mechanics in 5 Minutes	Superposition, entanglement and wave-particle duality — the strange truth of subatomic reality.	video	beginner	8	https://www.youtube.com/watch?v=7u_UQG1La1o	https://cdn.timewise.app/thumbs/sci-quantum.jpg	\N	t	en	4800000	4.80	12	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
233	10	The Theory of Evolution: Natural Selection Explained	Darwin's insight, genetic drift, speciation and the evidence that has built up since 1859.	video	beginner	15	https://www.youtube.com/watch?v=GhHOjC4oxh8	https://cdn.timewise.app/thumbs/sci-evolution.jpg	\N	t	en	6300000	4.90	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
234	10	How CRISPR Works: Gene Editing for Beginners	Bacterial immune system to world-changing biotech — what CRISPR-Cas9 actually does.	video	beginner	12	https://www.youtube.com/watch?v=jAhjPd4uNFY	https://cdn.timewise.app/thumbs/sci-crispr.jpg	\N	t	en	3900000	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
235	10	Climate Change: The Science in 12 Minutes	Greenhouse gases, feedback loops, tipping points and what the models actually say.	video	beginner	12	https://www.youtube.com/watch?v=EuwMB1Dal-4	https://cdn.timewise.app/thumbs/sci-climate.jpg	\N	t	en	5500000	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
236	10	How Black Holes Work	Event horizons, Hawking radiation and spaghettification — the physics made visual.	video	beginner	13	https://www.youtube.com/watch?v=e-P5IFTqB98	https://cdn.timewise.app/thumbs/sci-blackholes.jpg	\N	t	en	7100000	4.90	18	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
237	10	The Human Brain: A User's Guide	Neurons, neurotransmitters, cortex regions and what we still don't understand.	video	beginner	16	https://www.youtube.com/watch?v=pRFXSjkpKWA	https://cdn.timewise.app/thumbs/sci-brain.jpg	\N	t	en	4200000	4.80	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
238	10	The Periodic Table: A Story of Elements	How Mendeleev's table was built, what it predicts and the stories behind 10 key elements.	video	beginner	14	https://www.youtube.com/watch?v=0RRVV4Diomg	https://cdn.timewise.app/thumbs/sci-periodic.jpg	\N	t	en	3400000	4.70	18	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
239	10	What Is Dark Matter? The Universe's Biggest Mystery	Evidence, leading hypotheses and why 85% of the universe is invisible.	video	intermediate	14	https://www.youtube.com/watch?v=QAa2O_8wBUQ	https://cdn.timewise.app/thumbs/sci-dark-matter.jpg	\N	t	en	5200000	4.80	18	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
240	10	How Vaccines Work: The Immune System Explained	Antigens, antibodies, B-cells, T-cells and the difference between mRNA and traditional vaccines.	video	beginner	12	https://www.youtube.com/watch?v=rbfOoshNEMc	https://cdn.timewise.app/thumbs/sci-vaccines.jpg	\N	t	en	4100000	4.80	15	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
241	10	The Higgs Boson: Why the God Particle Matters	The Standard Model, the LHC and why finding the Higgs took 50 years.	video	intermediate	15	https://www.youtube.com/watch?v=RIg1Vh7uPyw	https://cdn.timewise.app/thumbs/sci-higgs.jpg	\N	t	en	3600000	4.70	20	2026-03-21 00:46:13.125318+03	t	\N	\N	\N	\N
\.


--
-- Data for Name: onboarding_questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.onboarding_questions (id, question_text, answer_type, display_order, is_active) FROM stdin;
1	Which topics spark your curiosity? Pick as many as you like.	multi_select	1	t
2	What do you usually want from a short break?	multi_select	2	t
3	How much free time do you typically have in one go?	single_select	3	t
4	How would you describe your level in your main interest area?	single_select	4	t
\.


--
-- Data for Name: progress; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.progress (id, user_id, content_id, completion_percentage, is_completed, last_updated) FROM stdin;
1	1	2	100	t	2026-03-21 00:46:13.140875+03
2	1	3	100	t	2026-03-21 00:46:13.140875+03
3	1	12	100	t	2026-03-21 00:46:13.140875+03
4	1	28	100	t	2026-03-21 00:46:13.140875+03
5	1	11	100	t	2026-03-21 00:46:13.140875+03
6	1	44	100	t	2026-03-21 00:46:13.140875+03
7	1	4	55	f	2026-03-21 00:46:13.140875+03
8	2	6	100	t	2026-03-21 00:46:13.140875+03
9	2	8	100	t	2026-03-21 00:46:13.140875+03
10	2	9	100	t	2026-03-21 00:46:13.140875+03
11	2	35	70	f	2026-03-21 00:46:13.140875+03
12	2	7	100	t	2026-03-21 00:46:13.140875+03
13	2	45	40	f	2026-03-21 00:46:13.140875+03
14	3	12	100	t	2026-03-21 00:46:13.140875+03
15	3	13	100	t	2026-03-21 00:46:13.140875+03
16	3	2	100	t	2026-03-21 00:46:13.140875+03
17	3	11	100	t	2026-03-21 00:46:13.140875+03
18	3	44	100	t	2026-03-21 00:46:13.140875+03
19	3	42	45	f	2026-03-21 00:46:13.140875+03
20	4	37	100	t	2026-03-21 00:46:13.140875+03
21	4	39	100	t	2026-03-21 00:46:13.140875+03
22	4	19	80	f	2026-03-21 00:46:13.140875+03
23	4	20	100	t	2026-03-21 00:46:13.140875+03
24	5	40	100	t	2026-03-21 00:46:13.140875+03
25	5	41	100	t	2026-03-21 00:46:13.140875+03
26	5	42	50	f	2026-03-21 00:46:13.140875+03
27	5	46	30	f	2026-03-21 00:46:13.140875+03
28	6	37	100	t	2026-03-21 00:46:13.140875+03
29	6	39	100	t	2026-03-21 00:46:13.140875+03
30	6	38	100	t	2026-03-21 00:46:13.140875+03
31	6	35	90	f	2026-03-21 00:46:13.140875+03
32	7	28	100	t	2026-03-21 00:46:13.140875+03
33	7	29	100	t	2026-03-21 00:46:13.140875+03
34	7	34	100	t	2026-03-21 00:46:13.140875+03
35	7	31	60	f	2026-03-21 00:46:13.140875+03
36	7	47	80	f	2026-03-21 00:46:13.140875+03
37	8	24	100	t	2026-03-21 00:46:13.140875+03
38	8	23	100	t	2026-03-21 00:46:13.140875+03
39	8	25	70	f	2026-03-21 00:46:13.140875+03
40	8	6	100	t	2026-03-21 00:46:13.140875+03
41	10	13	100	t	2026-03-21 08:45:03.308604+03
42	10	102	100	t	2026-03-21 08:45:03.994136+03
44	10	42	100	t	2026-03-21 12:08:58.966967+03
43	10	54	100	t	2026-03-21 12:09:09.020519+03
45	10	30	100	t	2026-03-21 12:12:28.886701+03
\.


--
-- Data for Name: recommendations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recommendations (id, session_id, content_id, score, rank, was_opened, reason_template, reason_text, created_at) FROM stdin;
1	1	2	89.00	1	t	matches_topic	Matches your Tech interest and fits your 15-minute window	2026-03-21 00:46:13.13885+03
2	1	12	82.50	2	t	matches_goal	Aligns with your learn goal — core ideas in 10 minutes	2026-03-21 00:46:13.13885+03
3	1	28	74.00	3	f	top_rated	Highly rated in General Culture — something new to explore	2026-03-21 00:46:13.13885+03
4	2	3	91.00	1	t	fits_duration	Fits your 25-minute window and matches your Tech interest	2026-03-21 00:46:13.13885+03
5	2	13	84.00	2	t	matches_goal	Actionable productivity system that fits your session goal	2026-03-21 00:46:13.13885+03
6	2	44	78.50	3	t	top_rated	Top-rated book summary — Atomic Habits in 10 minutes	2026-03-21 00:46:13.13885+03
7	3	11	88.00	1	t	matches_goal	Science-backed focus technique — perfect for a 7-minute break	2026-03-21 00:46:13.13885+03
8	3	33	79.50	2	t	fits_duration	Short stoic read that fits your 10-minute window	2026-03-21 00:46:13.13885+03
9	3	1	70.00	3	f	matches_topic	Quick mental model from your Tech interest area	2026-03-21 00:46:13.13885+03
10	4	4	93.00	1	t	matches_topic	Deep dive into AI — matches your top interest	2026-03-21 00:46:13.13885+03
11	4	29	88.00	2	t	top_rated	One of the highest-rated history pieces on the platform	2026-03-21 00:46:13.13885+03
12	4	5	77.00	3	f	fits_duration	Fills the remaining time and stays in your Tech zone	2026-03-21 00:46:13.13885+03
13	6	6	94.00	1	t	matches_topic	Your #1 interest — the essential language learning method	2026-03-21 00:46:13.13885+03
14	6	8	88.50	2	t	fits_duration	Flashcard set that fits exactly in your 10-minute window	2026-03-21 00:46:13.13885+03
15	6	11	72.00	3	f	matches_goal	Supports your learn goal with a quick productivity boost	2026-03-21 00:46:13.13885+03
16	7	9	89.00	1	t	matches_topic	Shadowing — the best pronunciation drill for language learners	2026-03-21 00:46:13.13885+03
17	7	35	80.00	2	t	matches_goal	Thinking traps — Psychology meets your learn goal	2026-03-21 00:46:13.13885+03
18	7	45	73.00	3	t	top_rated	Top-rated book summary — Thinking Fast and Slow	2026-03-21 00:46:13.13885+03
19	9	12	92.00	1	t	matches_topic	Your #1 topic — deep work is the productivity cornerstone	2026-03-21 00:46:13.13885+03
20	9	13	87.00	2	t	matches_goal	GTD system — directly supports your productive session goal	2026-03-21 00:46:13.13885+03
21	9	2	80.50	3	t	matches_topic	Prompt engineering — practical AI skill in your interest area	2026-03-21 00:46:13.13885+03
22	9	42	72.00	4	f	fits_duration	Lean startup overview fits your remaining session time	2026-03-21 00:46:13.13885+03
23	12	37	96.00	1	t	offline_available	Works offline — breathing reset in exactly 5 minutes	2026-03-21 00:46:13.13885+03
24	12	39	88.00	2	t	offline_available	Works offline — gratitude journaling for a creative mindset	2026-03-21 00:46:13.13885+03
25	12	19	81.00	3	f	matches_topic	Sketch-a-day habit matches your Arts & Crafts interest	2026-03-21 00:46:13.13885+03
26	14	40	94.00	1	t	matches_topic	Your #1 interest — compound interest explained with real numbers	2026-03-21 00:46:13.13885+03
27	14	41	86.50	2	t	fits_duration	Budget framework that fits your 10-minute window	2026-03-21 00:46:13.13885+03
28	14	32	71.00	3	f	top_rated	Most-played quiz on the platform — quick culture boost	2026-03-21 00:46:13.13885+03
29	16	37	97.00	1	t	offline_available	Works offline — top-rated breathing exercise for instant calm	2026-03-21 00:46:13.13885+03
30	16	39	91.00	2	t	offline_available	Works offline — gratitude journal aligns with your relax goal	2026-03-21 00:46:13.13885+03
31	16	47	84.00	3	f	matches_topic	Meditations by Marcus Aurelius — available offline, fits Philosophy interest	2026-03-21 00:46:13.13885+03
32	19	28	95.00	1	t	matches_topic	Your #1 interest — Roman Empire explained in 10 minutes	2026-03-21 00:46:13.13885+03
33	19	29	89.00	2	t	matches_topic	Cold War timeline — highly rated history piece	2026-03-21 00:46:13.13885+03
34	19	34	81.00	3	f	matches_topic	Existentialism — bridges your Culture and Philosophy interests	2026-03-21 00:46:13.13885+03
35	20	24	96.00	1	t	matches_topic	Your #1 interest — three guitar chords to start playing today	2026-03-21 00:46:13.13885+03
36	20	23	89.00	2	t	matches_topic	Sheet music basics — foundational for any instrument you pick up	2026-03-21 00:46:13.13885+03
37	20	25	81.00	3	f	matches_topic	Ear training drill — develops musical intuition in 10 minutes	2026-03-21 00:46:13.13885+03
38	21	124	92.40	1	f	fits_duration	Fits your 25-minute window very closely.	2026-03-20 21:52:24.872947+03
39	21	125	87.50	2	f	fits_duration	Fits your 25-minute window very closely.	2026-03-20 21:52:24.872952+03
40	21	20	84.40	3	f	fits_duration	Fits your 25-minute window very closely.	2026-03-20 21:52:24.872953+03
41	21	123	84.40	4	f	fits_duration	Fits your 25-minute window very closely.	2026-03-20 21:52:24.872954+03
42	21	126	84.30	5	f	fits_duration	Fits your 25-minute window very closely.	2026-03-20 21:52:24.872955+03
43	21	132	84.30	6	f	fits_duration	Fits your 25-minute window very closely.	2026-03-20 21:52:24.872956+03
44	22	62	72.81	1	f	fits_duration	Fits your 118-minute window very closely.	2026-03-20 21:54:03.247815+03
45	22	68	72.81	2	f	fits_duration	Fits your 118-minute window very closely.	2026-03-20 21:54:03.247817+03
46	22	48	72.71	3	f	fits_duration	Fits your 118-minute window very closely.	2026-03-20 21:54:03.247818+03
47	22	66	62.54	4	f	fits_duration	Fits your 118-minute window very closely.	2026-03-20 21:54:03.247819+03
48	22	79	62.54	5	f	fits_duration	Fits your 118-minute window very closely.	2026-03-20 21:54:03.24782+03
49	22	116	61.20	6	f	fits_duration	Fits your 118-minute window very closely.	2026-03-20 21:54:03.24782+03
50	23	62	72.81	1	f	fits_duration	Fits your 118-minute window very closely.	2026-03-20 21:54:05.492974+03
51	23	68	72.81	2	f	fits_duration	Fits your 118-minute window very closely.	2026-03-20 21:54:05.492979+03
52	23	48	72.71	3	f	fits_duration	Fits your 118-minute window very closely.	2026-03-20 21:54:05.49298+03
53	23	66	62.54	4	f	fits_duration	Fits your 118-minute window very closely.	2026-03-20 21:54:05.492982+03
54	23	79	62.54	5	f	fits_duration	Fits your 118-minute window very closely.	2026-03-20 21:54:05.492983+03
55	23	116	61.20	6	f	fits_duration	Fits your 118-minute window very closely.	2026-03-20 21:54:05.492984+03
56	24	135	92.40	1	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 06:34:09.282597+03
57	24	13	92.20	2	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 06:34:09.282599+03
58	24	131	92.20	3	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 06:34:09.2826+03
59	24	145	92.20	4	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 06:34:09.282601+03
60	24	172	89.73	5	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 06:34:09.282602+03
61	24	178	89.73	6	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 06:34:09.282603+03
62	25	91	64.07	1	f	fits_duration	Fits your 720-minute window very closely.	2026-03-21 06:37:09.623846+03
63	25	84	57.30	2	f	fits_duration	Fits your 720-minute window very closely.	2026-03-21 06:37:09.623856+03
64	25	62	57.30	3	f	matches_topic	Available offline and suitable for your current session.	2026-03-21 06:37:09.623857+03
65	25	48	57.20	4	f	matches_topic	Available offline and suitable for your current session.	2026-03-21 06:37:09.623858+03
66	25	66	55.53	5	f	matches_topic	Available offline and suitable for your current session.	2026-03-21 06:37:09.62386+03
67	25	67	54.04	6	f	matches_topic	Available offline and suitable for your current session.	2026-03-21 06:37:09.623861+03
68	26	135	92.40	1	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:06:36.692378+03
69	26	13	92.20	2	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:06:36.692382+03
70	26	131	92.20	3	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:06:36.692384+03
71	26	145	92.20	4	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:06:36.692385+03
72	26	172	89.73	5	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:06:36.692386+03
73	26	178	89.73	6	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:06:36.692387+03
74	27	135	92.40	1	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:15:26.805835+03
75	27	13	92.20	2	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:15:26.805841+03
76	27	131	92.20	3	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:15:26.805842+03
77	27	145	92.20	4	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:15:26.805843+03
78	27	172	89.73	5	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:15:26.805844+03
79	27	178	89.73	6	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:15:26.805844+03
80	28	135	92.40	1	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:17:36.203198+03
81	28	13	92.20	2	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:17:36.203202+03
82	28	131	92.20	3	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:17:36.203203+03
83	28	145	92.20	4	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:17:36.203205+03
84	28	172	89.73	5	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:17:36.203206+03
85	28	178	89.73	6	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:17:36.203207+03
86	29	135	92.40	1	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:37:13.623564+03
87	29	13	92.20	2	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:37:13.62357+03
88	29	131	92.20	3	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:37:13.623571+03
89	29	145	92.20	4	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:37:13.623572+03
90	29	30	92.10	5	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:37:13.623574+03
91	29	172	89.73	6	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 07:37:13.623575+03
92	30	135	92.40	1	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:13:26.011812+03
93	30	13	92.20	2	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:13:26.011815+03
94	30	131	92.20	3	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:13:26.011816+03
95	30	145	92.20	4	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:13:26.011817+03
96	30	172	89.73	5	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:13:26.011818+03
97	30	178	89.73	6	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:13:26.011818+03
98	31	135	82.40	1	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:13:44.804601+03
99	31	13	82.20	2	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:13:44.804604+03
100	31	131	82.20	3	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:13:44.804605+03
101	31	145	82.20	4	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:13:44.804606+03
102	31	172	79.73	5	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:13:44.804606+03
103	31	178	79.73	6	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:13:44.804607+03
104	32	60	88.97	1	f	fits_duration	Fits your 60-minute window very closely.	2026-03-21 08:40:02.88261+03
105	32	102	82.40	2	f	fits_duration	Fits your 60-minute window very closely.	2026-03-21 08:40:02.882613+03
106	32	79	77.20	3	f	fits_duration	Fits your 60-minute window very closely.	2026-03-21 08:40:02.882613+03
107	32	113	71.53	4	f	fits_duration	Fits your 60-minute window very closely.	2026-03-21 08:40:02.882614+03
108	32	121	71.53	5	f	fits_duration	Fits your 60-minute window very closely.	2026-03-21 08:40:02.882615+03
109	32	70	71.37	6	f	fits_duration	Fits your 60-minute window very closely.	2026-03-21 08:40:02.882616+03
110	33	135	92.40	1	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:59:52.843108+03
111	33	13	92.20	2	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:59:52.843112+03
112	33	131	92.20	3	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:59:52.843113+03
113	33	145	92.20	4	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:59:52.843114+03
114	33	172	89.73	5	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:59:52.843115+03
115	33	178	89.73	6	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 08:59:52.843116+03
116	34	135	92.40	1	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 09:00:03.851933+03
117	34	13	92.20	2	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 09:00:03.851939+03
118	34	131	92.20	3	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 09:00:03.851941+03
119	34	145	92.20	4	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 09:00:03.851943+03
120	34	172	89.73	5	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 09:00:03.851944+03
121	34	178	89.73	6	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 09:00:03.851946+03
122	35	54	85.63	1	f	fits_duration	Fits your 90-minute window very closely.	2026-03-21 09:00:40.540284+03
123	35	56	82.40	2	f	fits_duration	Fits your 90-minute window very closely.	2026-03-21 09:00:40.540291+03
124	35	103	82.30	3	f	fits_duration	Fits your 90-minute window very closely.	2026-03-21 09:00:40.540293+03
125	35	68	82.30	4	f	fits_duration	Fits your 90-minute window very closely.	2026-03-21 09:00:40.540295+03
126	35	119	76.77	5	f	fits_duration	Fits your 90-minute window very closely.	2026-03-21 09:00:40.540297+03
127	35	60	76.74	6	f	fits_duration	Fits your 90-minute window very closely.	2026-03-21 09:00:40.540298+03
128	36	20	91.90	1	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:03:51.666384+03
129	36	132	91.80	2	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:03:51.666389+03
130	36	144	91.80	3	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:03:51.66639+03
131	36	21	89.60	4	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:03:51.666391+03
132	36	143	88.50	5	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:03:51.666392+03
133	36	145	83.70	6	f	matches_topic	Matches your "Arts & Crafts" interest and available 25 minutes.	2026-03-21 12:03:51.666393+03
134	37	147	74.53	1	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 12:08:09.156043+03
135	37	31	69.20	2	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 12:08:09.156047+03
136	37	42	69.20	3	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 12:08:09.156048+03
137	37	36	69.10	4	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 12:08:09.15605+03
138	37	135	67.40	5	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 12:08:09.156051+03
139	37	92	67.30	6	f	fits_duration	Fits your 15-minute window very closely.	2026-03-21 12:08:09.156052+03
140	38	124	92.40	1	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:09:37.7649+03
141	38	125	87.50	2	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:09:37.764902+03
142	38	20	84.40	3	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:09:37.764903+03
143	38	123	84.40	4	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:09:37.764904+03
144	38	126	84.30	5	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:09:37.764905+03
145	38	132	84.30	6	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:09:37.764906+03
146	39	124	77.40	1	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:12:01.615106+03
147	39	30	76.10	2	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:12:01.615111+03
148	39	125	72.50	3	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:12:01.615112+03
149	39	20	69.40	4	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:12:01.615113+03
150	39	123	69.40	5	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:12:01.615114+03
151	39	126	69.30	6	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:12:01.615116+03
152	40	124	92.40	1	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:13:14.428532+03
153	40	125	87.50	2	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:13:14.428534+03
154	40	20	84.40	3	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:13:14.428534+03
155	40	123	84.40	4	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:13:14.428535+03
156	40	126	84.30	5	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:13:14.428536+03
157	40	132	84.30	6	f	fits_duration	Fits your 25-minute window very closely.	2026-03-21 12:13:14.428537+03
158	41	165	91.90	1	f	fits_duration	Fits your 25-minute window very closely.	2026-03-22 21:57:29.221401+03
159	41	158	91.80	2	f	fits_duration	Fits your 25-minute window very closely.	2026-03-22 21:57:29.221404+03
160	41	42	78.90	3	f	matches_topic	Matches your "Productivity" interest and available 25 minutes.	2026-03-22 21:57:29.221405+03
161	41	36	78.80	4	f	matches_topic	Matches your "Productivity" interest and available 25 minutes.	2026-03-22 21:57:29.221406+03
162	41	171	78.50	5	f	fits_duration	Fits your 25-minute window very closely.	2026-03-22 21:57:29.221407+03
163	41	12	75.80	6	f	matches_topic	Matches your "Productivity" interest and available 25 minutes.	2026-03-22 21:57:29.221408+03
\.


--
-- Data for Name: time_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.time_sessions (id, user_id, available_minutes, selected_goal, selected_difficulty, selected_topic_id, status, started_at, ended_at, is_offline, xp_earned) FROM stdin;
1	1	15	learn	intermediate	\N	completed	2026-03-11 00:46:13.137763+03	2026-03-11 01:01:13.137763+03	f	30
2	1	25	learn	intermediate	\N	completed	2026-03-13 00:46:13.137763+03	2026-03-13 01:10:13.137763+03	f	45
3	1	10	focus	beginner	\N	completed	2026-03-16 00:46:13.137763+03	2026-03-16 00:56:13.137763+03	f	20
4	1	40	productive	intermediate	\N	completed	2026-03-19 00:46:13.137763+03	2026-03-19 01:24:13.137763+03	f	65
5	1	20	learn	intermediate	\N	active	2026-03-21 00:16:13.137763+03	\N	f	0
6	2	10	learn	beginner	2	completed	2026-03-14 00:46:13.137763+03	2026-03-14 00:56:13.137763+03	f	20
7	2	15	learn	beginner	2	completed	2026-03-17 00:46:13.137763+03	2026-03-17 01:00:13.137763+03	f	25
8	2	8	relax	beginner	\N	completed	2026-03-20 00:46:13.137763+03	2026-03-20 00:54:13.137763+03	f	15
9	3	30	productive	intermediate	\N	completed	2026-03-12 00:46:13.137763+03	2026-03-12 01:15:13.137763+03	f	55
10	3	20	learn	intermediate	\N	completed	2026-03-17 00:46:13.137763+03	2026-03-17 01:06:13.137763+03	f	35
11	3	15	focus	intermediate	\N	abandoned	2026-03-20 00:46:13.137763+03	2026-03-20 00:52:13.137763+03	f	0
12	4	5	create	beginner	5	completed	2026-03-15 00:46:13.137763+03	2026-03-15 00:51:13.137763+03	t	10
13	4	10	create	beginner	5	completed	2026-03-18 00:46:13.137763+03	2026-03-18 00:56:13.137763+03	f	20
14	5	10	learn	beginner	10	completed	2026-03-16 00:46:13.137763+03	2026-03-16 00:56:13.137763+03	f	20
15	5	15	learn	beginner	10	completed	2026-03-19 00:46:13.137763+03	2026-03-19 01:00:13.137763+03	f	25
16	6	5	relax	beginner	11	completed	2026-03-17 00:46:13.137763+03	2026-03-17 00:51:13.137763+03	t	10
17	6	10	relax	beginner	11	completed	2026-03-19 00:46:13.137763+03	2026-03-19 00:56:13.137763+03	t	20
18	6	15	focus	beginner	\N	active	2026-03-21 00:26:13.137763+03	\N	f	0
19	7	15	learn	intermediate	7	completed	2026-03-18 00:46:13.137763+03	2026-03-18 01:01:13.137763+03	f	25
20	8	15	create	beginner	6	completed	2026-03-19 00:46:13.137763+03	2026-03-19 01:01:13.137763+03	f	25
21	10	25	relax	beginner	\N	active	2026-03-20 21:52:24.843558+03	\N	f	0
22	10	118	productive	advanced	\N	completed	2026-03-20 21:54:03.228574+03	\N	f	59
23	10	118	productive	advanced	\N	active	2026-03-20 21:54:05.475797+03	\N	f	0
24	10	15	learn	beginner	\N	active	2026-03-21 06:34:09.260773+03	\N	f	0
25	10	720	learn	beginner	\N	active	2026-03-21 06:37:09.574802+03	\N	f	0
26	10	15	learn	beginner	\N	active	2026-03-21 07:06:36.651568+03	\N	f	0
27	10	15	learn	beginner	\N	active	2026-03-21 07:15:26.780656+03	\N	f	0
28	10	15	learn	beginner	\N	active	2026-03-21 07:17:36.175766+03	\N	f	0
29	10	15	relax	beginner	\N	active	2026-03-21 07:37:13.602244+03	\N	f	0
30	10	15	learn	beginner	\N	active	2026-03-21 08:13:25.487567+03	\N	f	0
31	10	15	learn	advanced	\N	active	2026-03-21 08:13:44.742553+03	\N	f	0
32	10	60	relax	intermediate	\N	active	2026-03-21 08:40:02.854038+03	\N	f	0
33	10	15	learn	beginner	\N	active	2026-03-21 08:59:52.819636+03	\N	f	0
34	10	15	learn	beginner	\N	active	2026-03-21 09:00:03.830766+03	\N	f	0
35	10	90	relax	intermediate	\N	active	2026-03-21 09:00:40.518585+03	\N	f	0
36	10	25	learn	beginner	5	active	2026-03-21 12:03:50.865664+03	\N	f	0
37	10	15	focus	intermediate	\N	active	2026-03-21 12:08:09.132308+03	\N	f	0
38	10	25	learn	beginner	\N	active	2026-03-21 12:09:37.751741+03	\N	f	0
39	10	25	productive	beginner	\N	active	2026-03-21 12:12:01.589622+03	\N	f	0
40	10	25	learn	beginner	\N	active	2026-03-21 12:13:14.414853+03	\N	f	0
41	10	25	learn	intermediate	3	active	2026-03-22 21:57:29.19299+03	\N	t	0
\.


--
-- Data for Name: topic_subtags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.topic_subtags (id, topic_id, label, slug, display_order) FROM stdin;
1	1	AI Tools	ai-tools	1
2	1	No-Code	no-code	2
3	1	Web Basics	web-basics	3
4	1	Data & Analytics	data-analytics	4
5	2	Vocabulary	vocabulary	1
6	2	Pronunciation	pronunciation	2
7	2	Grammar	grammar	3
8	2	Listening	listening	4
9	3	Focus	focus	1
10	3	Planning	planning	2
11	3	Habits	habits	3
12	4	Exercise	exercise	1
13	4	Nutrition	nutrition	2
14	4	Sleep	sleep	3
15	4	Mental Wellness	mental-wellness	4
16	5	Drawing	drawing	1
17	5	Painting	painting	2
18	5	Printmaking	printmaking	3
19	5	DIY & Making	diy-making	4
20	6	Guitar	guitar	1
21	6	Music Theory	music-theory	2
22	6	Ear Training	ear-training	3
23	6	Sheet Music	sheet-music	4
24	7	History	history	1
25	7	Geography	geography	2
26	7	Science Trivia	science-trivia	3
27	8	Stoicism	stoicism	1
28	8	Ethics	ethics	2
29	8	Existentialism	existentialism	3
30	9	Motivation	motivation	1
31	9	Emotions	emotions	2
32	9	Thinking Traps	thinking-traps	3
33	10	Budgeting	budgeting	1
34	10	Investing	investing	2
35	10	Saving	saving	3
36	11	Breathing	breathing	1
37	11	Body Scan	body-scan	2
38	11	Journaling	journaling	3
39	12	Startups	startups	1
40	12	Product Thinking	product-thinking	2
41	12	Growth	growth	3
\.


--
-- Data for Name: topics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.topics (id, name, slug, description, icon_name, color_hex) FROM stdin;
1	Tech & Coding	tech	Programming, AI tools, software concepts and computer science	code	#6C63FF
2	Language Learning	languages	Any language — vocabulary, grammar, listening and speaking	globe	#00BFA5
3	Productivity	productivity	Focus, planning, habit building and time management	zap	#FF6B35
4	Health & Fitness	health	Exercise, nutrition, sleep and mental wellness	heart	#E91E8C
5	Arts & Crafts	arts	Drawing, painting, pottery, DIY and creative making	pen-tool	#FF9800
6	Music & Instruments	music	Learning instruments, music theory and ear training	music	#9C27B0
7	General Culture	culture	History, geography, science trivia and how the world works	book-open	#2196F3
8	Philosophy	philosophy	Schools of thought, ethics, logic and the big questions	book	#607D8B
9	Psychology	psychology	Motivation, emotions, thinking traps and self-understanding	brain	#F44336
10	Personal Finance	finance	Budgeting, saving, investing and financial independence	trending-up	#4CAF50
11	Meditation & Mindfulness	meditation	Breathing, body scans, mindfulness and stress relief	sun	#FFC107
12	Entrepreneurship	entrepreneurship	Startups, product thinking, growth and business basics	briefcase	#795548
\.


--
-- Data for Name: user_achievements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_achievements (id, user_id, achievement_id, earned_at) FROM stdin;
1	1	1	2026-03-11 00:46:13.142824+03
2	1	2	2026-03-13 00:46:13.142824+03
3	1	8	2026-03-16 00:46:13.142824+03
4	2	1	2026-03-14 00:46:13.142824+03
5	2	2	2026-03-17 00:46:13.142824+03
6	2	3	2026-03-20 00:46:13.142824+03
7	3	1	2026-03-12 00:46:13.142824+03
8	3	2	2026-03-15 00:46:13.142824+03
9	3	8	2026-03-17 00:46:13.142824+03
10	3	10	2026-03-19 00:46:13.142824+03
11	4	1	2026-03-15 00:46:13.142824+03
12	5	1	2026-03-16 00:46:13.142824+03
13	6	1	2026-03-17 00:46:13.142824+03
14	6	2	2026-03-19 00:46:13.142824+03
15	6	3	2026-03-20 00:46:13.142824+03
16	7	1	2026-03-18 00:46:13.142824+03
17	8	1	2026-03-19 00:46:13.142824+03
\.


--
-- Data for Name: user_onboarding_answers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_onboarding_answers (id, user_id, question_id, answer_value, answered_at) FROM stdin;
1	1	1	tech	2026-03-21 00:46:13.136897+03
2	1	1	productivity	2026-03-21 00:46:13.136897+03
3	1	1	culture	2026-03-21 00:46:13.136897+03
4	1	2	learn	2026-03-21 00:46:13.136897+03
5	1	3	15-30 min	2026-03-21 00:46:13.136897+03
6	1	4	intermediate	2026-03-21 00:46:13.136897+03
7	2	1	languages	2026-03-21 00:46:13.136897+03
8	2	1	psychology	2026-03-21 00:46:13.136897+03
9	2	1	meditation	2026-03-21 00:46:13.136897+03
10	2	2	learn	2026-03-21 00:46:13.136897+03
11	2	3	5-15 min	2026-03-21 00:46:13.136897+03
12	2	4	beginner	2026-03-21 00:46:13.136897+03
13	3	1	productivity	2026-03-21 00:46:13.136897+03
14	3	1	tech	2026-03-21 00:46:13.136897+03
15	3	1	finance	2026-03-21 00:46:13.136897+03
16	3	2	productive	2026-03-21 00:46:13.136897+03
17	3	3	15-30 min	2026-03-21 00:46:13.136897+03
18	3	4	intermediate	2026-03-21 00:46:13.136897+03
19	4	1	arts	2026-03-21 00:46:13.136897+03
20	4	1	music	2026-03-21 00:46:13.136897+03
21	4	1	philosophy	2026-03-21 00:46:13.136897+03
22	4	2	create	2026-03-21 00:46:13.136897+03
23	4	3	5-15 min	2026-03-21 00:46:13.136897+03
24	4	4	beginner	2026-03-21 00:46:13.136897+03
25	5	1	finance	2026-03-21 00:46:13.136897+03
26	5	1	entrepreneurship	2026-03-21 00:46:13.136897+03
27	5	1	culture	2026-03-21 00:46:13.136897+03
28	5	2	learn	2026-03-21 00:46:13.136897+03
29	5	3	10-20 min	2026-03-21 00:46:13.136897+03
30	5	4	beginner	2026-03-21 00:46:13.136897+03
31	6	1	meditation	2026-03-21 00:46:13.136897+03
32	6	1	psychology	2026-03-21 00:46:13.136897+03
33	6	1	philosophy	2026-03-21 00:46:13.136897+03
34	6	2	relax	2026-03-21 00:46:13.136897+03
35	6	3	5-10 min	2026-03-21 00:46:13.136897+03
36	6	4	beginner	2026-03-21 00:46:13.136897+03
37	7	1	culture	2026-03-21 00:46:13.136897+03
38	7	1	philosophy	2026-03-21 00:46:13.136897+03
39	7	2	learn	2026-03-21 00:46:13.136897+03
40	7	3	10-20 min	2026-03-21 00:46:13.136897+03
41	7	4	intermediate	2026-03-21 00:46:13.136897+03
42	8	1	music	2026-03-21 00:46:13.136897+03
43	8	1	arts	2026-03-21 00:46:13.136897+03
44	8	1	languages	2026-03-21 00:46:13.136897+03
45	8	2	create	2026-03-21 00:46:13.136897+03
46	8	3	15-30 min	2026-03-21 00:46:13.136897+03
47	8	4	beginner	2026-03-21 00:46:13.136897+03
\.


--
-- Data for Name: user_preferences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_preferences (id, user_id, default_goal, default_difficulty, prefer_offline, preferred_language, updated_at) FROM stdin;
1	1	learn	intermediate	f	en	2026-03-21 00:46:13.13566+03
2	2	learn	beginner	f	en	2026-03-21 00:46:13.13566+03
3	3	productive	intermediate	f	en	2026-03-21 00:46:13.13566+03
4	4	create	beginner	t	en	2026-03-21 00:46:13.13566+03
5	5	learn	beginner	f	en	2026-03-21 00:46:13.13566+03
6	6	relax	beginner	t	en	2026-03-21 00:46:13.13566+03
7	7	learn	intermediate	f	en	2026-03-21 00:46:13.13566+03
8	8	create	beginner	f	en	2026-03-21 00:46:13.13566+03
9	9	learn	beginner	f	en	2026-03-21 00:46:13.13566+03
\.


--
-- Data for Name: user_stats; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_stats (id, user_id, total_xp, current_level, current_streak_days, longest_streak_days, last_active_date, total_sessions, total_minutes_spent, total_contents_completed, favorite_topic_id, updated_at) FROM stdin;
1	1	235	3	4	8	2026-03-21	4	90	6	1	2026-03-21 00:46:13.142038+03
2	2	160	2	7	7	2026-03-21	3	33	5	2	2026-03-21 00:46:13.142038+03
3	3	240	3	2	12	2026-03-21	2	50	5	3	2026-03-21 00:46:13.142038+03
4	4	80	1	5	5	2026-03-21	2	15	3	5	2026-03-21 00:46:13.142038+03
5	5	90	1	1	4	2026-03-21	2	25	2	10	2026-03-21 00:46:13.142038+03
6	6	120	2	9	9	2026-03-21	2	15	3	11	2026-03-21 00:46:13.142038+03
7	7	100	1	3	6	2026-03-21	1	15	3	7	2026-03-21 00:46:13.142038+03
8	8	90	1	2	3	2026-03-21	1	15	3	6	2026-03-21 00:46:13.142038+03
9	9	0	1	0	0	\N	0	0	0	\N	2026-03-21 00:46:13.142038+03
10	10	59	1	0	0	\N	1	118	12	\N	2026-03-20 21:52:15.362732+03
\.


--
-- Data for Name: user_topics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_topics (id, user_id, topic_id, weight, source, created_at) FROM stdin;
1	1	1	9	onboarding	2026-03-21 00:46:13.136189+03
2	1	3	8	onboarding	2026-03-21 00:46:13.136189+03
3	1	7	6	onboarding	2026-03-21 00:46:13.136189+03
4	2	2	10	onboarding	2026-03-21 00:46:13.136189+03
5	2	9	7	onboarding	2026-03-21 00:46:13.136189+03
6	2	11	6	onboarding	2026-03-21 00:46:13.136189+03
7	3	3	10	onboarding	2026-03-21 00:46:13.136189+03
8	3	1	7	onboarding	2026-03-21 00:46:13.136189+03
9	3	10	6	onboarding	2026-03-21 00:46:13.136189+03
10	4	5	10	onboarding	2026-03-21 00:46:13.136189+03
11	4	6	8	onboarding	2026-03-21 00:46:13.136189+03
12	4	8	6	onboarding	2026-03-21 00:46:13.136189+03
13	5	10	10	onboarding	2026-03-21 00:46:13.136189+03
14	5	12	8	onboarding	2026-03-21 00:46:13.136189+03
15	5	7	6	onboarding	2026-03-21 00:46:13.136189+03
16	6	11	10	onboarding	2026-03-21 00:46:13.136189+03
17	6	9	9	onboarding	2026-03-21 00:46:13.136189+03
18	6	8	7	onboarding	2026-03-21 00:46:13.136189+03
19	7	7	10	onboarding	2026-03-21 00:46:13.136189+03
20	7	8	8	onboarding	2026-03-21 00:46:13.136189+03
21	7	9	5	onboarding	2026-03-21 00:46:13.136189+03
22	8	6	10	onboarding	2026-03-21 00:46:13.136189+03
23	8	5	8	onboarding	2026-03-21 00:46:13.136189+03
24	8	2	7	onboarding	2026-03-21 00:46:13.136189+03
25	10	3	7	onboarding	2026-03-20 21:52:20.562842+03
26	10	5	7	onboarding	2026-03-20 21:52:20.562849+03
27	10	7	7	onboarding	2026-03-20 21:52:20.562851+03
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, username, email, password_hash, display_name, avatar_url, onboarding_completed, created_at, is_active) FROM stdin;
1	alex_m	alex@example.com	$2b$12$hashed_password_1	Alex	\N	t	2026-03-21 00:46:13.134994+03	t
2	emily_r	emily@example.com	$2b$12$hashed_password_2	Emily	\N	t	2026-03-21 00:46:13.134994+03	t
3	marcus_w	marcus@example.com	$2b$12$hashed_password_3	Marcus	\N	t	2026-03-21 00:46:13.134994+03	t
4	claire_b	claire@example.com	$2b$12$hashed_password_4	Claire	\N	t	2026-03-21 00:46:13.134994+03	t
5	nathan_c	nathan@example.com	$2b$12$hashed_password_5	Nathan	\N	t	2026-03-21 00:46:13.134994+03	t
6	laura_s	laura@example.com	$2b$12$hashed_password_6	Laura	\N	t	2026-03-21 00:46:13.134994+03	t
7	james_p	james@example.com	$2b$12$hashed_password_7	James	\N	t	2026-03-21 00:46:13.134994+03	t
8	sofia_r	sofia@example.com	$2b$12$hashed_password_8	Sofia	\N	t	2026-03-21 00:46:13.134994+03	t
9	cerensevilen	cerensevilen@gmail.com	$2b$12$demoHashForCerenSevilen00	Ceren	\N	f	2026-03-21 00:46:13.134994+03	t
10	aleyna	aleynakiran123@hotmail.com	$2b$12$L8wLCOG5y3u0SwqgOAYwBO9u8L8J.s1OOXYJhuO8KpzbvYtRtECNO	\N	\N	t	2026-03-20 21:52:15.356776+03	t
\.


--
-- Name: achievements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.achievements_id_seq', 16, true);


--
-- Name: authors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.authors_id_seq', 10, true);


--
-- Name: bookmarks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.bookmarks_id_seq', 36, true);


--
-- Name: content_topics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.content_topics_id_seq', 282, true);


--
-- Name: contents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.contents_id_seq', 241, true);


--
-- Name: onboarding_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.onboarding_questions_id_seq', 4, true);


--
-- Name: progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.progress_id_seq', 45, true);


--
-- Name: recommendations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recommendations_id_seq', 163, true);


--
-- Name: time_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.time_sessions_id_seq', 41, true);


--
-- Name: topic_subtags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.topic_subtags_id_seq', 41, true);


--
-- Name: topics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.topics_id_seq', 12, true);


--
-- Name: user_achievements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_achievements_id_seq', 17, true);


--
-- Name: user_onboarding_answers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_onboarding_answers_id_seq', 47, true);


--
-- Name: user_preferences_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_preferences_id_seq', 9, true);


--
-- Name: user_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_stats_id_seq', 10, true);


--
-- Name: user_topics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_topics_id_seq', 27, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 10, true);


--
-- Name: achievements achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: achievements achievements_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_slug_key UNIQUE (slug);


--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: bookmarks bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: content_topics content_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_topics
    ADD CONSTRAINT content_topics_pkey PRIMARY KEY (id);


--
-- Name: contents contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contents
    ADD CONSTRAINT contents_pkey PRIMARY KEY (id);


--
-- Name: onboarding_questions onboarding_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onboarding_questions
    ADD CONSTRAINT onboarding_questions_pkey PRIMARY KEY (id);


--
-- Name: progress progress_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress
    ADD CONSTRAINT progress_pkey PRIMARY KEY (id);


--
-- Name: recommendations recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: time_sessions time_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_sessions
    ADD CONSTRAINT time_sessions_pkey PRIMARY KEY (id);


--
-- Name: topic_subtags topic_subtags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_subtags
    ADD CONSTRAINT topic_subtags_pkey PRIMARY KEY (id);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: bookmarks uq_bookmarks; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT uq_bookmarks UNIQUE (user_id, content_id);


--
-- Name: content_topics uq_content_topics; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_topics
    ADD CONSTRAINT uq_content_topics UNIQUE (content_id, topic_id);


--
-- Name: progress uq_progress; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress
    ADD CONSTRAINT uq_progress UNIQUE (user_id, content_id);


--
-- Name: recommendations uq_recommendations_session_rank; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT uq_recommendations_session_rank UNIQUE (session_id, rank);


--
-- Name: topic_subtags uq_subtag_slug; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_subtags
    ADD CONSTRAINT uq_subtag_slug UNIQUE (topic_id, slug);


--
-- Name: topics uq_topics_slug; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT uq_topics_slug UNIQUE (slug);


--
-- Name: user_achievements uq_user_achievements; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT uq_user_achievements UNIQUE (user_id, achievement_id);


--
-- Name: user_preferences uq_user_preferences_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT uq_user_preferences_user UNIQUE (user_id);


--
-- Name: user_stats uq_user_stats_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_stats
    ADD CONSTRAINT uq_user_stats_user UNIQUE (user_id);


--
-- Name: user_topics uq_user_topics; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_topics
    ADD CONSTRAINT uq_user_topics UNIQUE (user_id, topic_id);


--
-- Name: users uq_users_email; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uq_users_email UNIQUE (email);


--
-- Name: users uq_users_username; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uq_users_username UNIQUE (username);


--
-- Name: user_achievements user_achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_pkey PRIMARY KEY (id);


--
-- Name: user_onboarding_answers user_onboarding_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_onboarding_answers
    ADD CONSTRAINT user_onboarding_answers_pkey PRIMARY KEY (id);


--
-- Name: user_preferences user_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT user_preferences_pkey PRIMARY KEY (id);


--
-- Name: user_stats user_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_stats
    ADD CONSTRAINT user_stats_pkey PRIMARY KEY (id);


--
-- Name: user_topics user_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_topics
    ADD CONSTRAINT user_topics_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_bookmarks_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookmarks_user ON public.bookmarks USING btree (user_id);


--
-- Name: idx_contents_difficulty; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_contents_difficulty ON public.contents USING btree (difficulty);


--
-- Name: idx_contents_duration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_contents_duration ON public.contents USING btree (duration_minutes);


--
-- Name: idx_contents_offline; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_contents_offline ON public.contents USING btree (is_offline_available);


--
-- Name: idx_contents_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_contents_type ON public.contents USING btree (content_type);


--
-- Name: idx_progress_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_progress_user ON public.progress USING btree (user_id);


--
-- Name: idx_recommendations_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recommendations_session ON public.recommendations USING btree (session_id);


--
-- Name: idx_sessions_started; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_started ON public.time_sessions USING btree (started_at DESC);


--
-- Name: idx_sessions_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_user ON public.time_sessions USING btree (user_id);


--
-- Name: idx_subtags_topic; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subtags_topic ON public.topic_subtags USING btree (topic_id);


--
-- Name: idx_user_achievements_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_achievements_user ON public.user_achievements USING btree (user_id);


--
-- Name: vw_content_popularity _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.vw_content_popularity AS
 SELECT c.id,
    c.title,
    c.content_type,
    c.difficulty,
    c.duration_minutes,
    c.avg_rating,
    c.view_count,
    c.xp_reward,
        CASE
            WHEN (c.preview_video_url IS NOT NULL) THEN true
            ELSE false
        END AS has_preview,
    count(DISTINCT r.id) AS times_recommended,
    count(DISTINCT p.user_id) FILTER (WHERE p.is_completed) AS completions
   FROM ((public.contents c
     LEFT JOIN public.recommendations r ON ((r.content_id = c.id)))
     LEFT JOIN public.progress p ON ((p.content_id = c.id)))
  WHERE c.is_published
  GROUP BY c.id
  ORDER BY c.avg_rating DESC NULLS LAST, (count(DISTINCT r.id)) DESC;


--
-- Name: bookmarks bookmarks_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_content_id_fkey FOREIGN KEY (content_id) REFERENCES public.contents(id) ON DELETE CASCADE;


--
-- Name: bookmarks bookmarks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: content_topics content_topics_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_topics
    ADD CONSTRAINT content_topics_content_id_fkey FOREIGN KEY (content_id) REFERENCES public.contents(id) ON DELETE CASCADE;


--
-- Name: content_topics content_topics_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_topics
    ADD CONSTRAINT content_topics_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(id) ON DELETE CASCADE;


--
-- Name: contents contents_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contents
    ADD CONSTRAINT contents_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.authors(id) ON DELETE SET NULL;


--
-- Name: progress progress_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress
    ADD CONSTRAINT progress_content_id_fkey FOREIGN KEY (content_id) REFERENCES public.contents(id) ON DELETE CASCADE;


--
-- Name: progress progress_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.progress
    ADD CONSTRAINT progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: recommendations recommendations_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_content_id_fkey FOREIGN KEY (content_id) REFERENCES public.contents(id) ON DELETE CASCADE;


--
-- Name: recommendations recommendations_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.time_sessions(id) ON DELETE CASCADE;


--
-- Name: time_sessions time_sessions_selected_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_sessions
    ADD CONSTRAINT time_sessions_selected_topic_id_fkey FOREIGN KEY (selected_topic_id) REFERENCES public.topics(id) ON DELETE SET NULL;


--
-- Name: time_sessions time_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_sessions
    ADD CONSTRAINT time_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: topic_subtags topic_subtags_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_subtags
    ADD CONSTRAINT topic_subtags_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(id) ON DELETE CASCADE;


--
-- Name: user_achievements user_achievements_achievement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES public.achievements(id) ON DELETE CASCADE;


--
-- Name: user_achievements user_achievements_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_onboarding_answers user_onboarding_answers_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_onboarding_answers
    ADD CONSTRAINT user_onboarding_answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.onboarding_questions(id);


--
-- Name: user_onboarding_answers user_onboarding_answers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_onboarding_answers
    ADD CONSTRAINT user_onboarding_answers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_preferences user_preferences_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preferences
    ADD CONSTRAINT user_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_stats user_stats_favorite_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_stats
    ADD CONSTRAINT user_stats_favorite_topic_id_fkey FOREIGN KEY (favorite_topic_id) REFERENCES public.topics(id);


--
-- Name: user_stats user_stats_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_stats
    ADD CONSTRAINT user_stats_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_topics user_topics_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_topics
    ADD CONSTRAINT user_topics_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(id) ON DELETE CASCADE;


--
-- Name: user_topics user_topics_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_topics
    ADD CONSTRAINT user_topics_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict tpZswNX2bpBt3EgUVv227yYDd0OgZKleblH5vMOWCtXeR7lrWEEG4ymvghjwvzO

