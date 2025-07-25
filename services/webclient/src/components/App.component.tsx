import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

import Footer from "@components/Footer.component";
import Header from "@components/Header.component";
import Main from "@components/Main.component";

function App() {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000,
          },
        },
      }),
  );

  return (
    <QueryClientProvider client={queryClient}>
      <Header />
      <Main />
      <Footer />
    </QueryClientProvider>
  );
}

export default App;
