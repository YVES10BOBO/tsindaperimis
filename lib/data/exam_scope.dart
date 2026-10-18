import 'models.dart';

/// Ibibazo n'amasomo by'"ubumenyi bw'inyongera" (mekanike n'isuku y'imodoka).
/// Ni byiza kubimenya ariko ntibikunze kubazwa mu kizamini cy'uruhushya
/// rw'agateganyo, bityo ntibijya mu kizamini cy'igerageza.
/// ICYITONDERWA: genzura n'auto-école cyangwa Polisi, uhindure uru rutonde.
const Set<String> extraQuestionIds = <String>{
  // Ubumenyi ku Modoka: amavuta, amazi, feri, amapine, bateri, dashboard...
  'v1', 'v2', 'v3', 'v4', 'v5', 'v6', 'v8', 'v9', 'v10', 'v11', 'v12', 'v13',
  'v14', 'v15', 'v18', 'v20', 'v21', 'v22', 'v23', 'v24', 'v25', 'v26', 'v27',
  'v28', 'v29',
};

const Set<String> extraLessonIds = <String>{
  'modoka-1', // Igenzura rya buri munsi
  'modoka-2', // Amavuta ya moteri
  'modoka-3', // Amazi akonjesha moteri
  'modoka-5', // Amapine
  'modoka-7', // Dashboard
  'modoka-8', // Bateri, lisansi n'ibindi
};

bool isExamQuestion(Question q) => !extraQuestionIds.contains(q.id);
bool isExtraLesson(Lesson l) => extraLessonIds.contains(l.id);
