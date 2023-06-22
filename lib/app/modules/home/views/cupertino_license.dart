import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie/app/widget/window_appbar.dart';
import 'package:movie/config.dart';
import 'package:movie/utils/helper.dart';
import 'package:movie/widget/flutter_custom_license_page.dart';

CustomLicensePage cupertinoLicensePage = CustomLicensePage((
  context,
  licenseData,
) {
  return CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      backgroundColor: Get.isDarkMode ? Colors.black54 : Colors.white,
      previousPageTitle: 'LICENSE',
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
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.only(
              left: 12.0,
            ),
            child: Text(
              "开源地址: ",
              style: TextStyle(
                fontSize: 18,
                color: CupertinoColors.systemBlue,
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                LaunchURL(GITHUB_OPEN);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 12,
                      ),
                      Image.asset(
                        "assets/images/github_logo.png",
                        width: 81,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      const Text(
                        "开源地址ヾ(≧O≦)〃",
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.only(
              left: 12.0,
            ),
            child: Text(
              "以下是使用到的开源项目: ",
              style: TextStyle(
                fontSize: 18,
                color: CupertinoColors.systemBlue,
              ),
            ),
          ),
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
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
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
