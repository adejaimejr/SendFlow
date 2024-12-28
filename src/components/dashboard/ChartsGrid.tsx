import React from "react";
import CampaignStatusChart from "./CampaignStatusChart";
import MessageVolumeChart from "./MessageVolumeChart";

interface ChartsGridProps {
  campaignStatusData?: Array<{
    name: string;
    value: number;
    color: string;
  }>;
  messageVolumeData?: Array<{
    date: string;
    volume: number;
  }>;
}

const ChartsGrid = ({
  campaignStatusData,
  messageVolumeData,
}: ChartsGridProps) => {
  return (
    <div className="w-full bg-slate-900 p-6">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="w-full">
          <CampaignStatusChart data={campaignStatusData} />
        </div>
        <div className="w-full">
          <MessageVolumeChart data={messageVolumeData} />
        </div>
      </div>
    </div>
  );
};

export default ChartsGrid;
