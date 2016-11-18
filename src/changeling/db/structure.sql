--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: multipasses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE multipasses (
    reference_url character varying,
    requester character varying,
    impact character varying,
    impact_probability character varying,
    change_type character varying,
    peer_reviewer character varying,
    approver character varying,
    sre_approver character varying,
    testing boolean,
    backout_plan text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    team character varying,
    uuid uuid DEFAULT uuid_generate_v4() NOT NULL,
    merged boolean DEFAULT false,
    callback_url character varying,
    release_id character varying,
    emergency_approver character varying,
    title character varying
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    github_uid text,
    github_login text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    encrypted_github_token text,
    uuid uuid DEFAULT uuid_generate_v4() NOT NULL
);


--
-- Name: multipasses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY multipasses
    ADD CONSTRAINT multipasses_pkey PRIMARY KEY (uuid);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (uuid);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20151103222657');

INSERT INTO schema_migrations (version) VALUES ('20151106032009');

INSERT INTO schema_migrations (version) VALUES ('20151106045833');

INSERT INTO schema_migrations (version) VALUES ('20151111011859');

INSERT INTO schema_migrations (version) VALUES ('20151111012455');

INSERT INTO schema_migrations (version) VALUES ('20151111012558');

INSERT INTO schema_migrations (version) VALUES ('20151111091216');

INSERT INTO schema_migrations (version) VALUES ('20151112120747');

INSERT INTO schema_migrations (version) VALUES ('20151112121220');

INSERT INTO schema_migrations (version) VALUES ('20151114031546');

INSERT INTO schema_migrations (version) VALUES ('20151118014614');

INSERT INTO schema_migrations (version) VALUES ('20151125090341');

