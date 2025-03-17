import { OpenPanel } from "@openpanel/web";

export default defineNuxtPlugin(() => {
    const { public: { openPanelClientId, openPanelClientSecret } } =
        useRuntimeConfig();
    debugger;
    const openpanel = new OpenPanel({
        clientId: openPanelClientId,
        clientSecret: openPanelClientSecret,
        trackScreenViews: true,
        trackOutgoingLinks: true,
        trackAttributes: true,
    });

    // sec_c215c0ef46795df1cb8b

    return {
        provide: {
            openpanel,
        },
    };
});
