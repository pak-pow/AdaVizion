import "dotenv/config"
import { createClient } from "@supabase/supabase-js";

const supabaseUrl = `${process.env.SUPABASE_URL}`;
const supabaseServiceKey = `${process.env.SUPABASE_SERVICE_ROLE_KEY}`;

const supabase = createClient(supabaseUrl, supabaseServiceKey);

export { supabase };
