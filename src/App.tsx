import { Suspense } from "react";
import { Routes, Route, useLocation } from "react-router-dom";
import { MainLayout } from "./components/layout/MainLayout";
import Home from "./components/home";
import Clients from "./components/clients/Clients";

function App() {
  const location = useLocation();

  const getPageInfo = (pathname: string) => {
    switch (pathname) {
      case "/":
        return { title: "Dashboard", showPeriodSelector: true };
      case "/campaigns":
        return { title: "Campaigns", showPeriodSelector: false };
      case "/analytics":
        return { title: "Analytics", showPeriodSelector: true };
      case "/clients":
        return { title: "Clients", showPeriodSelector: false };
      case "/settings":
        return { title: "Settings", showPeriodSelector: false };
      default:
        return { title: "Dashboard", showPeriodSelector: true };
    }
  };

  const pageInfo = getPageInfo(location.pathname);

  return (
    <Suspense fallback={<p>Loading...</p>}>
      <MainLayout
        title={pageInfo.title}
        showPeriodSelector={pageInfo.showPeriodSelector}
      >
        <Routes>
          <Route path="/" element={<Home />} />
          <Route
            path="/campaigns"
            element={<div className="p-8 text-white">Campaigns Page</div>}
          />
          <Route
            path="/analytics"
            element={<div className="p-8 text-white">Analytics Page</div>}
          />
          <Route path="/clients" element={<Clients />} />
          <Route
            path="/settings"
            element={<div className="p-8 text-white">Settings Page</div>}
          />
        </Routes>
      </MainLayout>
    </Suspense>
  );
}

export default App;
