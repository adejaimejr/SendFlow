import React from "react";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { MoreHorizontal, Search } from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

interface Campaign {
  id: string;
  name: string;
  status: "active" | "completed" | "failed" | "pending";
  sentCount: number;
  successRate: number;
  lastUpdated: string;
}

interface CampaignTableProps {
  campaigns?: Campaign[];
  onSearch?: (query: string) => void;
}

const defaultCampaigns: Campaign[] = [
  {
    id: "1",
    name: "Q1 Newsletter",
    status: "active",
    sentCount: 1234,
    successRate: 98.5,
    lastUpdated: "2024-01-15",
  },
  {
    id: "2",
    name: "Welcome Series",
    status: "completed",
    sentCount: 5678,
    successRate: 99.1,
    lastUpdated: "2024-01-14",
  },
  {
    id: "3",
    name: "Promo Campaign",
    status: "failed",
    sentCount: 891,
    successRate: 45.2,
    lastUpdated: "2024-01-13",
  },
  {
    id: "4",
    name: "Product Update",
    status: "pending",
    sentCount: 0,
    successRate: 0,
    lastUpdated: "2024-01-12",
  },
];

const statusColors = {
  active: "bg-green-500",
  completed: "bg-blue-500",
  failed: "bg-red-500",
  pending: "bg-yellow-500",
};

const CampaignTable = ({
  campaigns = defaultCampaigns,
  onSearch = () => {},
}: CampaignTableProps) => {
  return (
    <Card className="w-full bg-slate-800 p-4 sm:p-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
        <h2 className="text-xl font-semibold text-white">Recent Campaigns</h2>
        <div className="relative w-full sm:w-64">
          <Search className="absolute left-2 top-2.5 h-4 w-4 text-slate-400" />
          <Input
            placeholder="Search campaigns..."
            className="pl-8 bg-slate-700 border-slate-600 text-white w-full"
            onChange={(e) => onSearch(e.target.value)}
          />
        </div>
      </div>

      <div className="rounded-md border border-slate-700 overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow className="border-slate-700">
              <TableHead className="text-slate-300 whitespace-nowrap">
                Campaign Name
              </TableHead>
              <TableHead className="text-slate-300 whitespace-nowrap">
                Status
              </TableHead>
              <TableHead className="text-slate-300 text-right whitespace-nowrap">
                Sent
              </TableHead>
              <TableHead className="text-slate-300 text-right whitespace-nowrap hidden sm:table-cell">
                Success Rate
              </TableHead>
              <TableHead className="text-slate-300 whitespace-nowrap hidden md:table-cell">
                Last Updated
              </TableHead>
              <TableHead className="text-slate-300 text-right whitespace-nowrap">
                Actions
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {campaigns.map((campaign) => (
              <TableRow key={campaign.id} className="border-slate-700">
                <TableCell className="font-medium text-white whitespace-nowrap">
                  {campaign.name}
                </TableCell>
                <TableCell>
                  <Badge
                    variant="secondary"
                    className={`${statusColors[campaign.status]} text-white whitespace-nowrap`}
                  >
                    {campaign.status}
                  </Badge>
                </TableCell>
                <TableCell className="text-right text-slate-300 whitespace-nowrap">
                  {campaign.sentCount.toLocaleString()}
                </TableCell>
                <TableCell className="text-right text-slate-300 whitespace-nowrap hidden sm:table-cell">
                  {campaign.successRate}%
                </TableCell>
                <TableCell className="text-slate-300 whitespace-nowrap hidden md:table-cell">
                  {campaign.lastUpdated}
                </TableCell>
                <TableCell className="text-right">
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button
                        variant="ghost"
                        className="h-8 w-8 p-0 text-slate-400 hover:text-white"
                      >
                        <MoreHorizontal className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent
                      align="end"
                      className="bg-slate-800 text-white border-slate-700"
                    >
                      <DropdownMenuItem className="cursor-pointer hover:bg-slate-700">
                        View Details
                      </DropdownMenuItem>
                      <DropdownMenuItem className="cursor-pointer hover:bg-slate-700">
                        Edit Campaign
                      </DropdownMenuItem>
                      <DropdownMenuItem className="cursor-pointer hover:bg-slate-700 text-red-400">
                        Delete
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </Card>
  );
};

export default CampaignTable;
