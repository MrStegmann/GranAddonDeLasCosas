
interface Item {
    id: string;
    name: string;
    icon: string;
    quality: string;
    description: string;
    tooltipLeft: string;
    tooltipRight: string;
};

type ItemsResponse = Item[];