import React from "react";
import MetricsGrid from "./dashboard/MetricsGrid";
import ChartsGrid from "./dashboard/ChartsGrid";
import CampaignTable from "./dashboard/CampaignTable";

interface HomeProps {
  selectedPeriod?: string;
  metrics?: {
    totalSent?: number;
    successRate?: number;
    activeCampaigns?: number;
    clientCount?: number;
  };
  campaignStatusData?: Array<{
    name: string;
    value: number;
    color: string;
  }>;
  messageVolumeData?: Array<{
    date: string;
    volume: number;
  }>;
  campaigns?: Array<{
    id: string;
    name: string;
    status: "active" | "completed" | "failed" | "pending";
    sentCount: number;
    successRate: number;
    lastUpdated: string;
  }>;
}

const Home = ({
  metrics,
  campaignStatusData,
  messageVolumeData,
  campaigns,
}: HomeProps) => {
  const handleSearch = (query: string) => {
    console.log("Search query:", query);
  };

  return (
    <div className="max-w-[1600px] mx-auto space-y-6">
      <MetricsGrid metrics={metrics} />
      <ChartsGrid
        campaignStatusData={campaignStatusData}
        messageVolumeData={messageVolumeData}
      />
      <CampaignTable campaigns={campaigns} onSearch={handleSearch} />
    </div>
  );
};

export default Home;
