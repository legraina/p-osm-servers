<?php
@define('CONST_Database_DSN', 'pgsql://@/' . getenv('PGDATABASE'));
@define('CONST_Database_Web_User', getenv('PGUSER'));
// How often upstream publishes diffs
@define('CONST_Replication_Update_Interval', '86400');
// How long to sleep if no update found yet
@define('CONST_Replication_Recheck_Interval', '900');
