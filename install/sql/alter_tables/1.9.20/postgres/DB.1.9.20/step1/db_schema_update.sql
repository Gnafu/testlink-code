﻿-- TestLink Open Source Project - http://testlink.sourceforge.net/
-- This script is distributed under the GNU General Public License 2 or later.
--
-- SQL script - Postgres

-- since 1.9.20
INSERT INTO /*prefix*/rights (id,description) VALUES (55,'testproject_add_remove_keywords_executed_tcversions');

ALTER TABLE /*prefix*/builds ADD COLUMN commit_id VARCHAR(64) NULL;
ALTER TABLE /*prefix*/builds ADD COLUMN tag VARCHAR(64) NULL;
ALTER TABLE /*prefix*/builds ADD COLUMN branch VARCHAR(64) NULL;
ALTER TABLE /*prefix*/builds ADD COLUMN release_candidate VARCHAR(100) NULL;
--
-- Table structure for table "testcase_platforms"
--
CREATE TABLE /*prefix*/testcase_platforms( 
  "id" BIGSERIAL NOT NULL , 
  "testcase_id" BIGINT NOT NULL DEFAULT '0' REFERENCES  /*prefix*/nodes_hierarchy (id),
  "tcversion_id" BIGINT NOT NULL DEFAULT '0' REFERENCES  /*prefix*/tcversions (id),
  "platform_id" BIGINT NOT NULL DEFAULT '0' REFERENCES  /*prefix*/platforms (id) ON DELETE CASCADE,
  PRIMARY KEY ("id")
); 
CREATE UNIQUE INDEX /*prefix*/idx01_testcase_platforms ON /*prefix*/testcase_platforms ("testcase_id","tcversion_id","platform_id");
CREATE INDEX /*prefix*/idx02_testcase_platforms ON /*prefix*/testcase_platforms ("tcversion_id");


-- 
--
CREATE OR REPLACE VIEW /*prefix*/latest_exec_by_testplan AS 
( 
  SELECT tcversion_id, testplan_id, MAX(id) AS id 
  FROM /*prefix*/executions 
  GROUP BY tcversion_id,testplan_id
);  
--

--
CREATE OR REPLACE VIEW /*prefix*/latest_exec_by_context AS 
(
  SELECT tcversion_id, testplan_id,build_id,platform_id,max(id) AS id
  FROM /*prefix*/executions 
  GROUP BY tcversion_id,testplan_id,build_id,platform_id
);


CREATE INDEX /*prefix*/nodes_hierarchy_node_type_id ON /*prefix*/nodes_hierarchy ("node_type_id");
CREATE INDEX /*prefix*/idx02_testcase_keywords ON /*prefix*/testcase_keywords ("tcversion_id");


--
--
CREATE OR REPLACE VIEW /*prefix*/tcversions_without_platforms AS 
( 
  SELECT NHTCV.parent_id AS testcase_id, NHTCV.id AS id
  FROM /*prefix*/nodes_hierarchy NHTCV 
  WHERE NHTCV.node_type_id = 4 
  AND NOT(EXISTS(SELECT 1 FROM /*prefix*/testcase_platforms TCPL
                 WHERE TCPL.tcversion_id = NHTCV.id ) )
);


-- END