import React from "react";
import ClientsMetrics from "./ClientsMetrics";
import ClientsTable from "./ClientsTable";

interface ClientsProps {
  metrics?: {
    totalClients?: number;
    activeClients?: number;
    newClientsMonth?: number;
    avgCampaigns?: number;
  };
}

const Clients = ({ metrics }: ClientsProps) => {
  const handleSearch = (query: string) => {
    console.log("Search query:", query);
  };

  return (
    <div className="max-w-[1600px] mx-auto space-y-6">
      <ClientsMetrics metrics={metrics} />
      <ClientsTable onSearch={handleSearch} />
    </div>
  );
};

export default Clients;
