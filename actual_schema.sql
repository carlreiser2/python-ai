CREATE EXTENSION vector;

CREATE TABLE public.subbet_log (
    "timestamp" timestamp without time zone,
    id character varying,
    collection_id character varying,
    document character varying,
    cmetadata jsonb
);

CREATE FUNCTION public.subbet_metadata_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO subbet_log (timestamp, id, collection_id, document, cmetadata)
    VALUES (NOW(), NEW.id, NEW.collection_id, NEW.document, NEW.cmetadata);
    RETURN NEW;
END;
$$;


CREATE FUNCTION public.subbets_ext__delete_existing_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM subbets_ext WHERE id = NEW.id;
    RETURN NEW;
END;
$$;


CREATE TABLE public.games_ext (
    id bigint,
    start_date text,
    sport_affiliation_id bigint,
    home_team_truth_id bigint,
    home_team_name text,
    home_display_name text,
    home_name_abbv_short text,
    home_name_abbv_med text,
    home_aff_name text,
    away_team_truth_id bigint,
    away_team_name text,
    away_display_name text,
    away_name_abbv_short text,
    away_name_abbv_med text,
    away_aff_name text,
    point_spread double precision,
    over_under double precision,
    home_team_implied_score double precision,
    away_team_implied_score double precision,
    home_team_moneyline double precision,
    away_team_moneyline double precision,
    home_team_final_score double precision,
    away_team_final_score double precision,
    status text,
    "createdAt" text,
    "updatedAt" text
);


CREATE TABLE public.langchain_pg_collection (
    uuid uuid NOT NULL,
    name character varying NOT NULL,
    cmetadata json
);

CREATE TABLE public.langchain_pg_embedding (
    id character varying NOT NULL,
    collection_id uuid,
    embedding public.vector,
    document character varying,
    cmetadata jsonb
);


CREATE VIEW public.langchain_pg_embedding__gms__g4a AS
 SELECT id,
    collection_id,
    embedding,
    document,
    cmetadata
   FROM public.langchain_pg_embedding lpe
  WHERE (collection_id IN ( SELECT lpc.uuid
           FROM public.langchain_pg_collection lpc
          WHERE ((lpc.name)::text = 'g4a__gms'::text)));


CREATE VIEW public.langchain_pg_embedding__pta__g4a AS
 SELECT id,
    collection_id,
    embedding,
    document,
    cmetadata
   FROM public.langchain_pg_embedding lpe
  WHERE (collection_id IN ( SELECT lpc.uuid
           FROM public.langchain_pg_collection lpc
          WHERE ((lpc.name)::text = 'g4a__pta'::text)));


--
-- TOC entry 229 (class 1259 OID 420392)
-- Name: langchain_pg_embedding__subbets__g4a; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.langchain_pg_embedding__subbets__g4a AS
 SELECT id,
    collection_id,
    embedding,
    document,
    cmetadata
   FROM public.langchain_pg_embedding lpe
  WHERE (collection_id IN ( SELECT lpc.uuid
           FROM public.langchain_pg_collection lpc
          WHERE ((lpc.name)::text = 'g4a__subbets'::text)));


--
-- TOC entry 237 (class 1259 OID 671368)
-- Name: players_embed_pta_; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.players_embed_pta_ AS
 SELECT (cmetadata ->> 'player_id'::text) AS player_id,
    (cmetadata ->> 'player_name'::text) AS player_name,
    (cmetadata ->> 'sport_affiliation_id'::text) AS sport_affiliation_id,
    (cmetadata ->> 'affiliation_name'::text) AS affiliation_name
   FROM public.langchain_pg_embedding__pta__g4a lpepga
  WHERE (((cmetadata ->> 'player_name'::text) <> 'Null'::text) AND ((cmetadata ->> 'affiliation_name'::text) <> 'Null'::text))
  GROUP BY (cmetadata ->> 'player_id'::text), (cmetadata ->> 'player_name'::text), (cmetadata ->> 'sport_affiliation_id'::text), (cmetadata ->> 'affiliation_name'::text);


--
-- TOC entry 219 (class 1259 OID 244269)
-- Name: players_ext; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.players_ext (
    player_id text,
    team_id text,
    sport_affiliation_id text,
    "position" text,
    number text,
    player_name text,
    team_name text,
    display_name text,
    name_abbv_short text,
    name_abbv_med text,
    affiliation_name text
);


--
-- TOC entry 228 (class 1259 OID 420331)
-- Name: subbet_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subbet_log (
    "timestamp" timestamp without time zone,
    id character varying,
    collection_id character varying,
    document character varying,
    cmetadata jsonb
);


--
-- TOC entry 223 (class 1259 OID 420281)
-- Name: subbets_embed_; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.subbets_embed_ AS
 SELECT id,
    document AS description,
    (cmetadata ->> 'subbet_type'::text) AS subbet_type,
    (cmetadata ->> 'metric'::text) AS metric,
    (cmetadata ->> 'duration'::text) AS duration,
    (cmetadata ->> 'position'::text) AS "position",
    (NULLIF((cmetadata ->> 'value'::text), ''::text))::double precision AS value,
    (NULLIF((cmetadata ->> 'vig'::text), ''::text))::double precision AS vig,
    (cmetadata ->> 'affiliation_name'::text) AS affiliation_name,
    (cmetadata ->> 'truth_team'::text) AS truth_team,
    (cmetadata ->> 'player_name'::text) AS player_name,
    (cmetadata ->> 'opp_truth_team'::text) AS opp_truth_team,
    (cmetadata ->> 'opp_player_name'::text) AS opp_player_name,
    (cmetadata ->> 'home_display_name'::text) AS home_display_name,
    (cmetadata ->> 'away_display_name'::text) AS away_display_name,
    (cmetadata ->> 'created_at'::text) AS created_at,
    (cmetadata ->> 'updated_at'::text) AS updated_at
   FROM public.langchain_pg_embedding__subbets__g4a lpe;


--
-- TOC entry 224 (class 1259 OID 420300)
-- Name: subbets_embed_queue; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.subbets_embed_queue AS
 SELECT id,
    description,
    subbet_type,
    metric,
    duration,
    "position",
    value,
    vig,
    affiliation_name,
    truth_team,
    player_name,
    opp_truth_team,
    opp_player_name,
    home_display_name,
    away_display_name,
    created_at,
    updated_at
   FROM public.subbets_embed_ se
  WHERE ((affiliation_name IS NULL) OR ((affiliation_name = 'Unknown'::text) AND (NOT ((id)::text IN ( SELECT sl.id
           FROM public.subbet_log sl)))));


--
-- TOC entry 225 (class 1259 OID 420304)
-- Name: subbets_embed_queue_dist; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.subbets_embed_queue_dist AS
 SELECT seq.id,
    lpe.id AS id_match,
    (qe.embedding OPERATOR(public.<->) lpe.embedding) AS distance
   FROM ((public.subbets_embed_queue seq
     JOIN public.langchain_pg_embedding__subbets__g4a qe ON (((qe.id)::text = (seq.id)::text)))
     JOIN LATERAL ( SELECT langchain_pg_embedding__subbets__g4a.id,
            langchain_pg_embedding__subbets__g4a.embedding
           FROM public.langchain_pg_embedding__subbets__g4a
          WHERE (NOT ((langchain_pg_embedding__subbets__g4a.id)::text IN ( SELECT subbets_embed_queue.id
                   FROM public.subbets_embed_queue)))
          ORDER BY (qe.embedding OPERATOR(public.<->) langchain_pg_embedding__subbets__g4a.embedding)
         LIMIT 1) lpe ON (true));


--
-- TOC entry 226 (class 1259 OID 420319)
-- Name: subbets_embed_queue_dist_match; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.subbets_embed_queue_dist_match AS
 SELECT lpe1.id,
    lpe1.document AS description,
    seqd.distance,
    lpe2.id AS id_match,
    lpe2.document AS match_description,
    (lpe2.cmetadata ->> 'subbet_type'::text) AS subbet_type,
    (lpe2.cmetadata ->> 'metric'::text) AS metric,
    (lpe2.cmetadata ->> 'duration'::text) AS duration,
    (lpe2.cmetadata ->> 'position'::text) AS "position",
    (lpe2.cmetadata ->> 'value'::text) AS value,
    (lpe1.cmetadata ->> 'vig'::text) AS vig,
    (lpe2.cmetadata ->> 'affiliation_name'::text) AS affiliation_name,
    (lpe2.cmetadata ->> 'truth_team'::text) AS truth_team,
    (lpe2.cmetadata ->> 'player_name'::text) AS player_name,
    (lpe2.cmetadata ->> 'opp_truth_team'::text) AS opp_truth_team,
    (lpe2.cmetadata ->> 'opp_player_name'::text) AS opp_player_name,
    (lpe2.cmetadata ->> 'home_display_name'::text) AS home_display_name,
    (lpe2.cmetadata ->> 'away_display_name'::text) AS away_display_name
   FROM ((public.subbets_embed_queue_dist seqd
     JOIN ( SELECT langchain_pg_embedding__subbets__g4a.id,
            langchain_pg_embedding__subbets__g4a.document,
            langchain_pg_embedding__subbets__g4a.cmetadata
           FROM public.langchain_pg_embedding__subbets__g4a) lpe1 ON (((lpe1.id)::text = (seqd.id)::text)))
     JOIN ( SELECT langchain_pg_embedding__subbets__g4a.id,
            langchain_pg_embedding__subbets__g4a.document,
            langchain_pg_embedding__subbets__g4a.cmetadata
           FROM public.langchain_pg_embedding__subbets__g4a) lpe2 ON (((lpe2.id)::text = (seqd.id_match)::text)));


--
-- TOC entry 221 (class 1259 OID 364306)
-- Name: subbets_ext; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subbets_ext (
    id bigint,
    description text,
    sport_affiliation_id bigint,
    affiliation_name text,
    subbet_type text,
    duration text,
    metric text,
    truth_team_id double precision,
    truth_team text,
    opp_truth_team_id double precision,
    opp_truth_team text,
    player_id double precision,
    player_name text,
    opp_player_id double precision,
    opp_player_name double precision,
    odds_jam_redis_odds_key text,
    "position" text,
    value double precision,
    vig double precision,
    game_id double precision,
    home_team_truth_id double precision,
    home_team_name text,
    home_display_name text,
    home_name_abbv_short text,
    home_name_abbv_med text,
    away_team_truth_id double precision,
    away_team_name text,
    away_display_name text,
    away_name_abbv_short text,
    away_name_abbv_med text,
    event_id double precision,
    is_standardized boolean,
    bet_id bigint,
    result_status_id double precision,
    start_date text,
    created_at text,
    updated_at text
);


--
-- TOC entry 233 (class 1259 OID 671330)
-- Name: subbets_queue; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.subbets_queue AS
 SELECT id,
    description,
    subbet_type,
    metric,
    duration,
    "position",
    value,
    vig,
    affiliation_name,
    truth_team,
    player_name,
    opp_truth_team,
    opp_player_name,
    home_display_name,
    away_display_name,
    created_at,
    updated_at
   FROM public.subbets_ext se
  WHERE (NOT (id IN ( SELECT (lpesga.id)::bigint AS id
           FROM public.langchain_pg_embedding__subbets__g4a lpesga)));


--
-- TOC entry 222 (class 1259 OID 420261)
-- Name: subbets_truth_; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.subbets_truth_ AS
 SELECT id,
    description,
    subbet_type,
    metric,
    duration,
    "position",
    value,
    vig,
    affiliation_name,
    truth_team,
    player_name,
    opp_truth_team,
    opp_player_name,
    home_display_name,
    away_display_name,
    created_at,
    updated_at
   FROM public.subbets_ext se
  WHERE ((subbet_type <> 'Unknown'::text) AND (subbet_type <> NULL::text));


--
-- TOC entry 227 (class 1259 OID 420326)
-- Name: subbets_truth_bool; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.subbets_truth_bool AS
 SELECT st.id,
    (NOT (st.description IS DISTINCT FROM (lpe.cmetadata ->> 'description'::text))) AS description,
    (NOT (st.subbet_type IS DISTINCT FROM (lpe.cmetadata ->> 'subbet_type'::text))) AS subbet_type,
    (NOT (st.metric IS DISTINCT FROM (lpe.cmetadata ->> 'metric'::text))) AS metric,
    (NOT (st.duration IS DISTINCT FROM (lpe.cmetadata ->> 'duration'::text))) AS duration,
    (NOT (st."position" IS DISTINCT FROM (lpe.cmetadata ->> 'position'::text))) AS "position",
    (NOT ((st.value)::text IS DISTINCT FROM (lpe.cmetadata ->> 'value'::text))) AS value,
    (NOT ((st.vig)::text IS DISTINCT FROM (lpe.cmetadata ->> 'vig'::text))) AS vig,
    (NOT (st.affiliation_name IS DISTINCT FROM (lpe.cmetadata ->> 'affiliation_name'::text))) AS affiliation_name,
    (NOT (st.truth_team IS DISTINCT FROM (lpe.cmetadata ->> 'truth_team'::text))) AS truth_team,
    (NOT (st.player_name IS DISTINCT FROM (lpe.cmetadata ->> 'player_name'::text))) AS player_name,
    (NOT (st.opp_truth_team IS DISTINCT FROM (lpe.cmetadata ->> 'opp_truth_team'::text))) AS opp_truth_team,
    (NOT ((st.opp_player_name)::text IS DISTINCT FROM (lpe.cmetadata ->> 'opp_player_name'::text))) AS opp_player_name,
    (NOT (st.home_display_name IS DISTINCT FROM (lpe.cmetadata ->> 'home_display_name'::text))) AS home_display_name,
    (NOT (st.away_display_name IS DISTINCT FROM (lpe.cmetadata ->> 'away_display_name'::text))) AS away_display_name,
    (NOT (st.created_at IS DISTINCT FROM (lpe.cmetadata ->> 'created_at'::text))) AS created_at,
    (NOT (st.updated_at IS DISTINCT FROM (lpe.cmetadata ->> 'udpated_at'::text))) AS updated_at
   FROM (public.subbets_truth_ st
     JOIN public.langchain_pg_embedding lpe ON (((lpe.id)::text = (st.id)::text)))
  WHERE (st.updated_at < (lpe.cmetadata ->> 'updated_at'::text));


--
-- TOC entry 232 (class 1259 OID 670755)
-- Name: subbets_truth_bool_sums; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.subbets_truth_bool_sums AS
 SELECT se.affiliation_name AS group_name,
    count(stb.id) AS total_count,
    sum(
        CASE
            WHEN stb.description THEN 1
            ELSE 0
        END) AS description,
    sum(
        CASE
            WHEN stb.subbet_type THEN 1
            ELSE 0
        END) AS subbet_type,
    sum(
        CASE
            WHEN stb.metric THEN 1
            ELSE 0
        END) AS metric,
    sum(
        CASE
            WHEN stb.duration THEN 1
            ELSE 0
        END) AS duration,
    sum(
        CASE
            WHEN stb."position" THEN 1
            ELSE 0
        END) AS "position",
    sum(
        CASE
            WHEN stb.value THEN 1
            ELSE 0
        END) AS value,
    sum(
        CASE
            WHEN stb.vig THEN 1
            ELSE 0
        END) AS vig,
    sum(
        CASE
            WHEN stb.affiliation_name THEN 1
            ELSE 0
        END) AS affiliation_name,
    sum(
        CASE
            WHEN stb.truth_team THEN 1
            ELSE 0
        END) AS truth_team,
    sum(
        CASE
            WHEN stb.player_name THEN 1
            ELSE 0
        END) AS player_name,
    sum(
        CASE
            WHEN stb.opp_truth_team THEN 1
            ELSE 0
        END) AS opp_truth_team,
    sum(
        CASE
            WHEN stb.opp_player_name THEN 1
            ELSE 0
        END) AS opp_player_name,
    sum(
        CASE
            WHEN stb.home_display_name THEN 1
            ELSE 0
        END) AS home_display_name,
    sum(
        CASE
            WHEN stb.away_display_name THEN 1
            ELSE 0
        END) AS away_display_name,
    sum(
        CASE
            WHEN stb.created_at THEN 1
            ELSE 0
        END) AS created_at,
    sum(
        CASE
            WHEN stb.updated_at THEN 1
            ELSE 0
        END) AS updated_at
   FROM (public.subbets_truth_bool stb
     JOIN public.subbets_embed_ se ON (((se.id)::text = (stb.id)::text)))
  GROUP BY se.affiliation_name
  ORDER BY (count(stb.id)) DESC;


--
-- TOC entry 235 (class 1259 OID 671355)
-- Name: subbets_truth_players; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.subbets_truth_players AS
 SELECT player_id,
    player_name,
    sport_affiliation_id,
    affiliation_name
   FROM ( SELECT se.player_id,
            se.player_name,
            se.sport_affiliation_id,
            se.affiliation_name
           FROM public.subbets_ext se
          WHERE (((se.player_id)::text <> 'NULL'::text) AND (se.player_name <> 'NULL'::text) AND (se.affiliation_name <> 'NULL'::text) AND (se.affiliation_name <> 'Unknown'::text))
          GROUP BY se.player_id, se.player_name, se.sport_affiliation_id, se.affiliation_name
        UNION
         SELECT se2.opp_player_id AS player_id,
            (se2.opp_player_name)::text AS player_name,
            se2.sport_affiliation_id,
            se2.affiliation_name
           FROM public.subbets_ext se2
          WHERE (((se2.opp_player_id)::text <> 'NULL'::text) AND ((se2.opp_player_name)::text <> 'NULL'::text) AND (se2.affiliation_name <> 'NULL'::text) AND (se2.affiliation_name <> 'Unknown'::text))
          GROUP BY se2.opp_player_id, se2.opp_player_name, se2.sport_affiliation_id, se2.affiliation_name) se_;


--
-- TOC entry 234 (class 1259 OID 671344)
-- Name: subbets_truth_teams; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.subbets_truth_teams AS
 SELECT truth_team_id,
    truth_team,
    sport_affiliation_id,
    affiliation_name
   FROM ( SELECT se.truth_team_id,
            se.truth_team,
            se.sport_affiliation_id,
            se.affiliation_name
           FROM public.subbets_ext se
          WHERE (((se.truth_team_id)::text <> 'NULL'::text) AND (se.truth_team <> 'NULL'::text) AND (se.affiliation_name <> 'NULL'::text) AND (se.affiliation_name <> 'Unknown'::text))
          GROUP BY se.truth_team_id, se.truth_team, se.sport_affiliation_id, se.affiliation_name
        UNION
         SELECT se2.opp_truth_team_id AS truth_team_id,
            se2.opp_truth_team AS truth_team,
            se2.sport_affiliation_id,
            se2.affiliation_name
           FROM public.subbets_ext se2
          WHERE (((se2.opp_truth_team_id)::text <> 'NULL'::text) AND (se2.opp_truth_team <> 'NULL'::text) AND (se2.affiliation_name <> 'NULL'::text) AND (se2.affiliation_name <> 'Unknown'::text))
          GROUP BY se2.opp_truth_team_id, se2.opp_truth_team, se2.sport_affiliation_id, se2.affiliation_name) se_;


--
-- TOC entry 236 (class 1259 OID 671364)
-- Name: teams_embed_pta_; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.teams_embed_pta_ AS
 SELECT (cmetadata ->> 'team_id'::text) AS team_id,
    (cmetadata ->> 'team_name'::text) AS team_name,
    (cmetadata ->> 'sport_affiliation_id'::text) AS sport_affiliation_id,
    (cmetadata ->> 'affiliation_name'::text) AS affiliation_name
   FROM public.langchain_pg_embedding__pta__g4a lpepga
  WHERE (((cmetadata ->> 'team_name'::text) <> 'Null'::text) AND ((cmetadata ->> 'affiliation_name'::text) <> 'Null'::text))
  GROUP BY (cmetadata ->> 'team_id'::text), (cmetadata ->> 'team_name'::text), (cmetadata ->> 'sport_affiliation_id'::text), (cmetadata ->> 'affiliation_name'::text);
