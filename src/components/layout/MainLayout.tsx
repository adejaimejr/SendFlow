import { useState } from "react";
import { Sidebar } from "./Sidebar";
import { Header } from "./Header";

interface MainLayoutProps {
  children: React.ReactNode;
  title: string;
  showPeriodSelector?: boolean;
}

export function MainLayout({
  children,
  title,
  showPeriodSelector,
}: MainLayoutProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="flex min-h-screen bg-slate-900">
      <Sidebar
        className="w-64 border-r border-slate-700 fixed left-0 top-0 h-screen transition-transform duration-300 ease-in-out lg:translate-x-0 z-50"
        isOpen={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
      />
      <div className="flex-1 lg:ml-64 transition-all duration-300 ease-in-out">
        <Header
          title={title}
          showPeriodSelector={showPeriodSelector}
          selectedPeriod="7d"
          onPeriodChange={(value) => console.log("Period changed:", value)}
          onMenuClick={() => setSidebarOpen(true)}
        />
        <main className="min-h-[calc(100vh-4rem)] p-4 sm:p-6 lg:p-8">
          {children}
        </main>
      </div>
    </div>
  );
}
