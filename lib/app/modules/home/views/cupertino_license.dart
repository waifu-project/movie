import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movie/app/widget/window_appbar.dart';
import 'package:movie/widget/flutter_custom_license_page.dart';

CustomLicensePage cupertinoLicensePage = CustomLicensePage((
  context,
  licenseData,
) {
  return CupertinoPageScaffold(
    navigationBar: CupertinoEasyAppBar(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CupertinoNavigationBarBackButton(),
              Expanded(
                child: Text(
                  "License",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Text(''),
            ],
          ),
          const Divider(),
        ],
      ),
    ),
    child: body(licenseData, context),
  );
});

Widget body(
  AsyncSnapshot<LicenseData> licenseDataFuture,
  BuildContext context,
) {
  switch (licenseDataFuture.connectionState) {
    case ConnectionState.done:
      LicenseData? licenseData = licenseDataFuture.data;
      return ListView(
        children: [
          ...licenseDataFuture.data!.packages.map(
            (currentPackage) => CupertinoButton(
              child: Text(
                currentPackage,
              ),
              onPressed: () {
                List<LicenseEntry> packageLicenses = licenseData!
                    .packageLicenseBindings[currentPackage]!
                    .map((binding) => licenseData.licenses[binding])
                    .toList();
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) {
                    return CupertinoPageScaffold(
                      navigationBar: CupertinoEasyAppBar(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const CupertinoNavigationBarBackButton(),
                                Expanded(
                                  child: Text(
                                    currentPackage,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                const Text(''),
                              ],
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                      child: Material(
                        child: ListView.builder(
                          itemCount: packageLicenses.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                packageLicenses[index]
                                    .paragraphs
                                    .map((paragraph) => paragraph.text)
                                    .join("\n"),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      );

    default:
      return const Center(
        child: CupertinoActivityIndicator(),
      );
  }
}
