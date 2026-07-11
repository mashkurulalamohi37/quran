class InheritanceResult {
  final Map<String, double> shares; // Relatives and their percentage shares
  final double husbandShare;
  final double wifeShare;
  final double fatherShare;
  final double motherShare;
  final double sonShare; // Share of EACH son
  final double daughterShare; // Share of EACH daughter
  final double totalDistributed;
  final String explanation; // Explanation of how shares were calculated in Bengali

  const InheritanceResult({
    required this.shares,
    required this.husbandShare,
    required this.wifeShare,
    required this.fatherShare,
    required this.motherShare,
    required this.sonShare,
    required this.daughterShare,
    required this.totalDistributed,
    required this.explanation,
  });
}

class InheritanceCalculator {
  static InheritanceResult calculate({
    required bool hasHusband,
    required bool hasWife,
    required int numWives,
    required int numSons,
    required int numDaughters,
    required bool hasFather,
    required bool hasMother,
  }) {
    double husband = 0.0;
    double wife = 0.0;
    double father = 0.0;
    double mother = 0.0;
    double sonsTotal = 0.0;
    double daughtersTotal = 0.0;

    final hasChildren = (numSons > 0 || numDaughters > 0);
    List<String> steps = [];

    // 1. Spousal Share
    if (hasHusband) {
      if (hasChildren) {
        husband = 0.25; // 1/4
        steps.add("সন্তান থাকায় স্বামী পাবেন মোট সম্পত্তির ১/৪ অংশ (২৫%)।");
      } else {
        husband = 0.50; // 1/2
        steps.add("সন্তান না থাকায় স্বামী পাবেন মোট সম্পত্তির ১/২ অংশ (৫০%)।");
      }
    } else if (hasWife && numWives > 0) {
      if (hasChildren) {
        wife = 0.125; // 1/8
        steps.add("সন্তান থাকায় স্ত্রী পাবেন মোট সম্পত্তির ১/৮ অংশ (১২.৫%) যা স্ত্রী সংখ্যা অনুযায়ী সমানভাগে বিভক্ত হবে।");
      } else {
        wife = 0.25; // 1/4
        steps.add("সন্তান না থাকায় স্ত্রী পাবেন মোট সম্পত্তির ১/৪ অংশ (২৫%) যা স্ত্রী সংখ্যা অনুযায়ী সমানভাগে বিভক্ত হবে।");
      }
    }

    // 2. Parents' Shares
    if (hasMother) {
      if (hasChildren) {
        mother = 1.0 / 6.0; // 1/6
        steps.add("সন্তান থাকায় মাতা পাবেন মোট সম্পত্তির ১/৬ অংশ (১৬.৬৭%)।");
      } else {
        mother = 1.0 / 3.0; // 1/3
        steps.add("সন্তান না থাকায় মাতা পাবেন মোট সম্পত্তির ১/৩ অংশ (৩৩.৩৩%)।");
      }
    }

    if (hasFather) {
      if (hasChildren) {
        father = 1.0 / 6.0; // 1/6 as fixed sharer
        steps.add("সন্তান থাকায় পিতা নিশ্চিত অংশ হিসেবে পাবেন ১/৬ অংশ (১৬.৬৭%)।");
      } else {
        // Father gets nothing as a fixed sharer, he gets everything that remains (residuary)
        father = 0.0;
      }
    }

    // 3. Daughters' Share (when there are no sons, daughters are fixed sharers)
    double fixedDaughters = 0.0;
    if (numSons == 0 && numDaughters > 0) {
      if (numDaughters == 1) {
        fixedDaughters = 0.50; // 1/2
        steps.add("কোনো পুত্র না থাকায় এক কন্যা পাবেন সম্পত্তির ১/২ অংশ (৫০%)।");
      } else {
        fixedDaughters = 2.0 / 3.0; // 2/3
        steps.add("কোনো পুত্র না থাকায় একাধিক কন্যা যৌথভাবে পাবেন সম্পত্তির ২/৩ অংশ (৬৬.৬৭%)।");
      }
    }

    // Sum of all fixed sharers
    double sumSharers = husband + wife + mother + father + fixedDaughters;

    // ── AUL (عول) RULE ──
    // If fixed shares exceed 100% (1.0), we scale them down proportionally
    if (sumSharers > 1.0) {
      final scale = 1.0 / sumSharers;
      husband *= scale;
      wife *= scale;
      mother *= scale;
      father *= scale;
      fixedDaughters *= scale;
      sumSharers = 1.0;
      steps.add("স্থিরীকৃত অংশীদারদের মোট ভাগের পরিমাণ ১০০% অতিক্রম করায় 'আউল' (Aul) নিয়মানুযায়ী সকলের প্রাপ্ত অংশ সমানুপাতিক হারে হ্রাস করা হলো।");
    }

    double remainder = 1.0 - sumSharers;

    // 4. Residuary Distribution (আসাবা - Asabah)
    if (remainder > 0.0) {
      if (numSons > 0) {
        // Sons and daughters share remainder in 2:1 ratio
        final totalParts = (numSons * 2) + numDaughters;
        final partShare = remainder / totalParts;
        sonsTotal = partShare * 2 * numSons;
        daughtersTotal = partShare * numDaughters;
        steps.add("স্থিরীকৃত অংশ বণ্টনের পর অবশিষ্ট অংশ (${(remainder * 100).toStringAsFixed(2)}%) পুত্র ও কন্যাদের মধ্যে ২:১ অনুপাতে বণ্টন করা হলো (আসাবা নিয়মে)।");
      } else if (hasFather) {
        // If no sons, father takes the remainder as residuary
        father += remainder;
        steps.add("স্থিরীকৃত অংশ বণ্টনের পর অবশিষ্ট অংশ (${(remainder * 100).toStringAsFixed(2)}%) পিতা আসাবা (Residuary) হিসেবে পাবেন।");
        remainder = 0.0;
      } else if (numDaughters > 0) {
        // ── RADD (رد) RULE ──
        // If there are no male residuaries (sons/father), the remainder returns to the sharers (mother & daughters)
        // Spouse (husband/wife) classical Islamic law doesn't get Radd.
        double raddPool = mother + fixedDaughters;
        if (raddPool > 0.0) {
          final mRatio = mother / raddPool;
          final dRatio = fixedDaughters / raddPool;
          mother += remainder * mRatio;
          fixedDaughters += remainder * dRatio;
          steps.add("কোনো আসাবা (পুরুষ উত্তরাধিকারী) না থাকায় অবশিষ্ট অংশ (${(remainder * 100).toStringAsFixed(2)}%) 'রাদ' (Radd) নিয়মানুযায়ী মা ও কন্যাদের মধ্যে পুনরায় বণ্টন করা হলো।");
          remainder = 0.0;
        }
      }
    }

    // Prepare final results
    final Map<String, double> shares = {};
    if (hasHusband && husband > 0) shares['স্বামী'] = husband;
    if (hasWife && wife > 0) shares['স্ত্রী (সকল)'] = wife;
    if (hasFather && father > 0) shares['পিতা'] = father;
    if (hasMother && mother > 0) shares['মাতা'] = mother;

    double perSon = 0.0;
    if (numSons > 0) {
      perSon = sonsTotal / numSons;
      shares['প্রতি পুত্র (${_toBengaliNum(numSons)} জন)'] = perSon;
    }

    double perDaughter = 0.0;
    if (numDaughters > 0) {
      perDaughter = numSons > 0 ? (daughtersTotal / numDaughters) : (fixedDaughters / numDaughters);
      shares['প্রতি কন্যা (${_toBengaliNum(numDaughters)} জন)'] = perDaughter;
    }

    double totalVal = husband + wife + father + mother + sonsTotal + (numSons > 0 ? daughtersTotal : fixedDaughters);

    return InheritanceResult(
      shares: shares,
      husbandShare: husband,
      wifeShare: wife,
      fatherShare: father,
      motherShare: mother,
      sonShare: perSon,
      daughterShare: perDaughter,
      totalDistributed: totalVal,
      explanation: steps.join("\n\n"),
    );
  }

  static String _toBengaliNum(int n) {
    const digits = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    return n.toString().split('').map((c) => digits[int.parse(c)]).join();
  }
}
