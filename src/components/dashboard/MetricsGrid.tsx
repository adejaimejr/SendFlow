import React from "react";
import MetricCard from "./MetricCard";
import { MessageCircle, CheckCircle, PlayCircle, Users } from "lucide-react";

interface MetricsGridProps {
  metrics?: {
    totalSent?: number;
    successRate?: number;
    activeCampaigns?: number;
    clientCount?: number;
  };
}

const MetricsGrid = ({
  metrics = {
    totalSent: 1234567,
    successRate: 98.5,
    activeCampaigns: 42,
    clientCount: 156,
  },
}: MetricsGridProps) => {
  return (
    <div className="w-full bg-slate-900">
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 sm:gap-6">
        <MetricCard
          icon={<MessageCircle className="w-6 h-6 text-blue-400" />}
          label="Total Messages Sent"
          value={metrics.totalSent?.toLocaleString()}
          trend={12}
          trendLabel="vs last month"
        />

        <MetricCard
          icon={<CheckCircle className="w-6 h-6 text-green-400" />}
          label="Success Rate"
          value={`${metrics.successRate}%`}
          trend={2.5}
          trendLabel="vs last month"
        />

        <MetricCard
          icon={<PlayCircle className="w-6 h-6 text-yellow-400" />}
          label="Active Campaigns"
          value={metrics.activeCampaigns}
          trend={-5}
          trendLabel="vs last month"
        />

        <MetricCard
          icon={<Users className="w-6 h-6 text-purple-400" />}
          label="Total Clients"
          value={metrics.clientCount}
          trend={8}
          trendLabel="vs last month"
        />
      </div>
    </div>
  );
};

export default MetricsGrid;
