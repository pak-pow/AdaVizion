import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET as string;
const TOKEN_EXPIRY = '1h';

function generateAuthToken(studentNum: string) {
  return jwt.sign(
    { studentNum: studentNum },
    JWT_SECRET,
    { expiresIn: TOKEN_EXPIRY }
  );
}

export {
  generateAuthToken
}
