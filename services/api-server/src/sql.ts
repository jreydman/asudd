import { SQL } from "bun";

const sql = new SQL({
  url: process.env.DATABASE_URL,
});

export default sql;
