import React from "react";
import MetricCard from "../dashboard/MetricCard";
import { Users, UserCheck, Building, Clock } from "lucide-react";

interface ClientsMetricsProps {
  metrics?: {
    totalClients?: number;
    activeClients?: number;
    newClientsMonth?: number;
    avgCampaigns?: number;
  };
}

const ClientsMetrics = ({
  metrics = {
    totalClients: 156,
    activeClients: 142,
    newClientsMonth: 8,
    avgCampaigns: 6.3,
  },
}: ClientsMetricsProps) => {
  return (
    <div className="w-full bg-slate-900">
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 sm:gap-6">
        <MetricCard
          icon={<Users className="w-6 h-6 text-blue-400" />}
          label="Total Clients"
          value={metrics.totalClients}
          trend={5}
          trendLabel="vs last month"
        />

        <MetricCard
          icon={<UserCheck className="w-6 h-6 text-green-400" />}
          label="Active Clients"
          value={metrics.activeClients}
          trend={2}
          trendLabel="vs last month"
        />

        <MetricCard
          icon={<Building className="w-6 h-6 text-purple-400" />}
          label="New This Month"
          value={metrics.newClientsMonth}
          trend={-2}
          trendLabel="vs last month"
        />

        <MetricCard
          icon={<Clock className="w-6 h-6 text-yellow-400" />}
          label="Avg. Campaigns/Client"
          value={metrics.avgCampaigns}
          trend={0.5}
          trendLabel="vs last month"
        />
      </div>
    </div>
  );
};

export default ClientsMetrics;
