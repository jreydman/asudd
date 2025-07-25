import { StrictMode } from "react";
import { createRoot } from "react-dom/client";

import "@src/style.css";

import App from "@components/App.component.tsx";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
