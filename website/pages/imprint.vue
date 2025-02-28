<template>
  <SharedBackHomeButton />

  <div class="min-h-screen py-16 px-4">
    <div class="max-w-3xl mx-auto">
      <h1 class="text-4xl font-bold mb-8 text-gray-800 dark:text-white">
        Imprint & Legal Information
      </h1>

      <div class="space-y-8 text-gray-600 dark:text-gray-300">
        <!-- Imprint Section -->
        <section class="space-y-4">
          <h2
            class="text-2xl font-semibold mb-4 text-gray-700 dark:text-gray-100"
          >
            Information according to § 5 TMG
          </h2>
          <p>
            <strong>Address</strong><br />
            Leo Gall <br />
            Föhrenweg 21 <br />
            86926 Greifenberg <br />
            Bavaria, Germany
          </p>
          <div class="space-y-1">
            <p>
              <strong>E-Mail: </strong>
              <SharedContactEmail />
            </p>
          </div>
        </section>

        <!-- Disclaimer Section -->
        <section>
          <h2
            class="text-2xl font-semibold mb-4 text-gray-700 dark:text-gray-100"
          >
            Disclaimer
          </h2>
          <h3 class="text-xl font-semibold mb-2 mt-5">
            Liability for Contents
          </h3>
          <p>
            The contents of our pages were created with the utmost care.
            However, we cannot guarantee the accuracy, completeness, and
            timeliness of the content. As a service provider, we are responsible
            for our own content on these pages under the general laws according
            to § 7 para.1 TMG. According to §§ 8 to 10 TMG, we are not obligated
            as a service provider to monitor transmitted or stored third-party
            information or to investigate circumstances that indicate illegal
            activity. Obligations to remove or block the use of information
            under the general laws remain unaffected. However, liability in this
            regard is only possible from the point in time at which a concrete
            infringement of the law becomes known. If we become aware of any
            such infringements, we will remove this content immediately.
          </p>
          <h3 class="text-xl font-semibold mb-2 mt-5">Liability for Links</h3>
          <p>
            Our offer contains links to external websites of third parties, on
            whose contents we have no influence. Therefore, we cannot assume any
            liability for these external contents. The respective provider or
            operator of the pages is always responsible for the content of the
            linked pages. The linked pages were checked for possible legal
            violations at the time of linking. Illegal contents were not
            recognizable at the time of linking. However, a permanent control of
            the contents of the linked pages is not reasonable without concrete
            evidence of a violation of the law. If we become aware of any
            infringements, we will remove such links immediately.
          </p>
        </section>

        <!-- Copyright Section -->
        <section>
          <h2
            class="text-2xl font-semibold mb-4 text-gray-700 dark:text-gray-100"
          >
            Copyright
          </h2>
          <p>
            The content and works created by the site operators on these pages
            are subject to German copyright law. The reproduction, editing,
            distribution, and any kind of exploitation outside the limits of
            copyright require the written consent of the respective author or
            creator. Downloads and copies of this site are only permitted for
            private, non-commercial use. Insofar as the content on this site was
            not created by the operator, the copyrights of third parties are
            respected. In particular, third-party content is identified as such.
            Should you nevertheless become aware of a copyright infringement,
            please inform us accordingly. If we become aware of any
            infringements, we will remove such content immediately.
          </p>
        </section>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
useHead({
  title: "Daytistics - Imprint",
});
</script>
