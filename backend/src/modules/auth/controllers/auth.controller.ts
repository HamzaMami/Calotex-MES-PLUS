import { Request, Response } from "express";

import * as authService from "../services/auth.service";
import { IAuthTokens } from "../interfaces/auth.interface";
import { LoginRequestDTO, RegisterRequestDTO, CreateUserByAdminDTO, CompleteRegistrationDTO, RefreshTokenDTO } from "../dto/auth.dto";

/** Shape the token pair into the response contract expected by the client. */
const toAuthResponse = (tokens: IAuthTokens) => ({
  access_token: tokens.accessToken,
  refresh_token: tokens.refreshToken,
  expires_in: tokens.expiresIn,
  token_type: "Bearer",
  user: tokens.user,
});

export const login = async (
  req: Request<{}, {}, LoginRequestDTO>,
  res: Response
) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    const tokens = await authService.login(email, password);

    res.status(200).json({
      success: true,
      message: "Login successful",
      data: toAuthResponse(tokens),
    });
  } catch (error: any) {
    res.status(401).json({
      success: false,
      message: error.message || "Login failed",
    });
  }
};

export const register = async (
  req: Request<{}, {}, RegisterRequestDTO>,
  res: Response
) => {
  try {
    const { name, email, password, roleId } = req.body;

    // Validation
    if (!name || !email || !password || !roleId) {
      return res.status(400).json({
        success: false,
        message: "Name, email, password, and roleId are required",
      });
    }

    const user = await authService.register(name, email, password, roleId);

    res.status(201).json({
      success: true,
      message: "User registered successfully",
      data: user,
    });
  } catch (error: any) {
    res.status(400).json({
      success: false,
      message: error.message || "Registration failed",
    });
  }
};

export const createUserByAdmin = async (
  req: Request<{}, {}, CreateUserByAdminDTO>,
  res: Response
) => {
  try {
    const { email, roleId } = req.body;

    // Validation
    if (!email || !roleId) {
      return res.status(400).json({
        success: false,
        message: "Email and roleId are required",
      });
    }

    // Get base URL from request
    const baseUrl = `${req.protocol}://${req.get("host")}/api/auth`;

    const data = await authService.createUserByAdmin(email, roleId, baseUrl);

    res.status(201).json({
      success: true,
      message: "User created successfully. Registration email sent.",
      data,
    });
  } catch (error: any) {
    res.status(400).json({
      success: false,
      message: error.message || "Failed to create user",
    });
  }
};

export const completeRegistration = async (
  req: Request<{ token: string }, {}, CompleteRegistrationDTO>,
  res: Response
) => {
  try {
    const { token } = req.params;
    const { fullName, password, passwordConfirm } = req.body;

    // Validation
    if (!token || !fullName || !password || !passwordConfirm) {
      return res.status(400).json({
        success: false,
        message: "Token, full name, password, and password confirmation are required",
      });
    }

    const user = await authService.completeRegistration(
      token,
      fullName,
      password,
      passwordConfirm
    );

    res.status(200).json({
      success: true,
      message: "Registration completed successfully. You can now login.",
      data: user,
    });
  } catch (error: any) {
    res.status(400).json({
      success: false,
      message: error.message || "Failed to complete registration",
    });
  }
};

export const refreshToken = async (
  req: Request<{}, {}, RefreshTokenDTO>,
  res: Response
) => {
  try {
    const { refresh_token: refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        message: "Refresh token is required",
      });
    }

    const tokens = await authService.refreshTokens(refreshToken);

    res.status(200).json({
      success: true,
      message: "Token refreshed successfully",
      data: toAuthResponse(tokens),
    });
  } catch (error: any) {
    res.status(401).json({
      success: false,
      message: error.message || "Failed to refresh token",
    });
  }
};

export const logout = async (_req: Request, res: Response) => {
  // Access/refresh tokens are stateless JWTs, so logout is primarily a
  // client-side concern (clearing stored tokens). This endpoint acknowledges
  // the request and provides a hook for future server-side revocation.
  res.status(200).json({
    success: true,
    message: "Logged out successfully",
  });
};