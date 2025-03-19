import { OpenPanel } from "@openpanel/web";

export default defineNuxtPlugin(() => {
    const { public: { openPanelClientId } } = useRuntimeConfig();
    const openpanel = new OpenPanel({
        clientId: openPanelClientId,
        trackScreenViews: true,
        trackOutgoingLinks: true,
        trackAttributes: true,
    });

    return {
        provide: {
            openpanel,
        },
    };
});
