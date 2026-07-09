part of 'hotel_detail_screen_view.dart';

class HotelDetailScreenViewController extends GetxController {
  final currentIndex = 0.obs;



  void changeIndex(int index) {
    currentIndex.value = index;
  }

  void showNearbyBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Text(
              "nearby_poplular".tr,
              style: GoogleFonts.googleSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),

            const SizedBox(height: 20),

            Divider(height: 1, color: Theme.of(context).dividerColor),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSectionTitle(context, "trending".tr),

                  const SizedBox(height: 16),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: 8,
                    itemBuilder: (_, __) => _buildPlaceItem(context),
                  ),

                  const SizedBox(height: 20),

                  _buildSectionTitle(context, "near_places".tr),

                  const SizedBox(height: 16),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: 8,
                    itemBuilder: (_, __) => _buildPlaceItem(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.googleSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildPlaceItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              "Farm Link",
              style: GoogleFonts.googleSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.titleSmall?.color,
              ),
            ),
          ),

          Text(
            "770 m",
            style: GoogleFonts.googleSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.titleSmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
