--
-- PostgreSQL database dump
--

-- Dumped from database version 14.3 (Debian 14.3-1.pgdg100+1)
-- Dumped by pg_dump version 14.3 (Debian 14.3-1.pgdg100+1)

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
-- Name: log_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            INSERT INTO audit(operation, updated)
                VALUES(TG_OP,row_to_json(NEW));
        RETURN NEW;
        ELSEIF (TG_OP = 'UPDATE') THEN
            INSERT INTO audit(operation, previous, updated)
                VALUES(TG_OP, row_to_json(OLD), row_to_json(NEW));
        RETURN NEW;
        ELSEIF (TG_OP = 'DELETE') THEN
            INSERT INTO audit(operation, previous)
                VALUES(TG_OP, row_to_json(OLD));
        RETURN OLD;
        END IF;
    END;
$$;


ALTER FUNCTION public.log_change() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit (
    id bigint NOT NULL,
    operation text,
    username text DEFAULT CURRENT_USER,
    timelog timestamp without time zone DEFAULT now(),
    previous json,
    updated json
);


ALTER TABLE public.audit OWNER TO postgres;

--
-- Name: audit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audit_id_seq OWNER TO postgres;

--
-- Name: audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_id_seq OWNED BY public.audit.id;


--
-- Name: road_network; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.road_network (
    id integer NOT NULL,
    name text,
    location text,
    desciption text,
    lat double precision,
    lon double precision
);


ALTER TABLE public.road_network OWNER TO postgres;

--
-- Name: road_network_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.road_network_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.road_network_id_seq OWNER TO postgres;

--
-- Name: road_network_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.road_network_id_seq OWNED BY public.road_network.id;


--
-- Name: audit id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit ALTER COLUMN id SET DEFAULT nextval('public.audit_id_seq'::regclass);


--
-- Name: road_network id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.road_network ALTER COLUMN id SET DEFAULT nextval('public.road_network_id_seq'::regclass);


--
-- Data for Name: audit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit (id, operation, username, timelog, previous, updated) FROM stdin;
1	INSERT	postgres	2022-06-02 19:47:23.906692	\N	{"id":3,"name":"my street","location":"Edmonton","desciption":"speeding","lat":56.213231,"lon":23.123123}
2	INSERT	postgres	2022-06-02 19:48:16.991816	\N	{"id":4,"name":"john street","location":"Calgary","desciption":"Speeding","lat":54.213,"lon":23.231}
3	INSERT	postgres	2022-06-03 00:47:40.028242	\N	{"id":5,"name":"94 street","location":"Edmonton","desciption":"High speeding count","lat":54.3232,"lon":21.3213}
4	DELETE	postgres	2022-06-03 01:19:34.159916	{"id":3,"name":"my street","location":"Edmonton","desciption":"speeding","lat":56.213231,"lon":23.123123}	\N
5	DELETE	postgres	2022-06-03 01:19:46.877974	{"id":2,"name":"my street","location":"Edmonton","desciption":"speeding","lat":56.213231,"lon":23.123123}	\N
\.


--
-- Data for Name: road_network; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.road_network (id, name, location, desciption, lat, lon) FROM stdin;
1	edmonton street	Edmonton	Speeding	54.213	23.231
4	john street	Calgary	Speeding	54.213	23.231
5	94 street	Edmonton	High speeding count	54.3232	21.3213
\.


--
-- Name: audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_id_seq', 5, true);


--
-- Name: road_network_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.road_network_id_seq', 5, true);


--
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);


--
-- Name: road_network road_network_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.road_network
    ADD CONSTRAINT road_network_pkey PRIMARY KEY (id);


--
-- Name: road_network check_change_after; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_change_after AFTER INSERT OR DELETE OR UPDATE ON public.road_network FOR EACH ROW EXECUTE FUNCTION public.log_change();


--
-- PostgreSQL database dump complete
--

