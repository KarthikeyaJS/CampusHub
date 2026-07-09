import 'package:campus_hub/features/auth/domain/usecases/register_usecase_student.dart';
import 'package:campus_hub/features/complaints/presentation/cubit/complaint_detail_cubit/complaint_detail_cubit.dart';
import 'package:campus_hub/features/venues/domain/usecases/get_venue_by_id_usecase.dart';
import 'package:campus_hub/features/venues/presentation/cubit/create_booking_cubit/create_booking_cubit.dart';
import 'package:campus_hub/features/venues/presentation/cubit/my_bookings_cubit/my_booking_cubit.dart';
import 'package:campus_hub/features/venues/presentation/cubit/venue_list_cubit/venue_list_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import '../features/auth/presentation/cubit/login_cubit/login_cubit.dart';
import '../features/auth/presentation/cubit/register_cubit/register_cubit.dart';
import '../core/constants/cloudinary_constants.dart';
import '../core/services/cloudinary_service.dart';
import '../features/complaints/data/datasources/complaint_remote_datasource.dart';
import '../features/complaints/data/repositories/complaint_repository_impl.dart';
import '../features/complaints/domain/repositories/complaint_repository.dart';
import '../features/complaints/domain/usecases/create_complaint_usecase.dart';
import '../features/complaints/domain/usecases/get_my_complaints_usecase.dart';
import '../features/complaints/domain/usecases/get_complaint_by_id_usecase.dart';
import '../features/complaints/presentation/cubit/create_complaint_cubit/create_complaint_cubit.dart';
import '../features/complaints/presentation/cubit/my_complaints_cubit/my_complaints_cubit.dart';
import '../features/venues/data/datasources/venue_remote_datasource.dart';
import '../features/venues/data/datasources/booking_remote_datasource.dart';
import '../features/venues/data/repositories/venue_repository_impl.dart';
import '../features/venues/domain/repositories/venue_repository.dart';
import '../features/venues/domain/usecases/get_venues_usecase.dart';
import '../features/venues/domain/usecases/create_booking_usecase.dart';
import '../features/venues/domain/usecases/get_my_bookings_usecase.dart';
import '../features/venues/presentation/cubit/venue_detail_cubit/venue_detail_cubit.dart';
import '../features/venues/domain/usecases/get_booking_by_id_usecase.dart';
import '../features/venues/domain/usecases/update_booking_usecase.dart';
import '../features/venues/domain/usecases/cancel_booking_usecase.dart';
import '../features/venues/presentation/cubit/booking_detail_cubit/booking_detail_cubit.dart';
import '../features/venues/presentation/cubit/booking_action_cubit/booking_action_cubit.dart';

import '../features/venues/domain/usecases/get_bookings_for_coordinator_usecase.dart';
import '../features/venues/domain/usecases/approve_booking_usecase.dart';
import '../features/venues/domain/usecases/reject_booking_usecase.dart';
import '../features/venues/presentation/cubit/coordinator_approvals_cubit/coordinator_approvals_cubit.dart';
import '../features/venues/presentation/cubit/approval_action_cubit/approval_action_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ---- External (Firebase SDK instances) ----
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // ---- Auth Feature ----
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterStudentUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // AuthStateCubit lives for the app's lifetime -> singleton
  sl.registerLazySingleton(() => AuthStateCubit(sl()));

  // LoginCubit/RegisterCubit are per-screen -> new instance each time
  sl.registerFactory(() => LoginCubit(sl()));
  sl.registerFactory(() => RegisterCubit(sl()));

  // ---- Cloudinary ----
  sl.registerLazySingleton(
    () => const CloudinaryService(
      cloudName: CloudinaryConstants.cloudName,
      uploadPreset: CloudinaryConstants.uploadPreset,
    ),
  );

  // ---- Complaints Feature ----
  sl.registerLazySingleton<ComplaintRemoteDataSource>(
    () => ComplaintRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      cloudinaryService: sl(),
    ),
  );

  sl.registerLazySingleton<ComplaintRepository>(
    () => ComplaintRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => CreateComplaintUseCase(sl()));
  sl.registerLazySingleton(() => GetMyComplaintsUseCase(sl()));
  sl.registerLazySingleton(() => GetComplaintByIdUseCase(sl()));

  sl.registerFactory(() => CreateComplaintCubit(sl()));
  sl.registerFactory(
    () => MyComplaintsCubit(getMyComplaintsUseCase: sl(), firebaseAuth: sl()),
  );
  sl.registerFactory(() => ComplaintDetailCubit(sl()));
  // ---- Venues & Bookings Feature ----
  sl.registerLazySingleton<VenueRemoteDataSource>(
    () => VenueRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );

  sl.registerLazySingleton<VenueRepository>(
    () => VenueRepositoryImpl(venueDataSource: sl(), bookingDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetVenuesUseCase(sl()));
  sl.registerLazySingleton(() => GetVenueByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetMyBookingsUseCase(sl()));
  sl.registerFactory(() => VenueListCubit(sl()));
  sl.registerFactory(() => CreateBookingCubit(sl()));
  sl.registerFactory(
    () => MyBookingsCubit(getMyBookingsUseCase: sl(), firebaseAuth: sl()),
  );
  sl.registerFactory(() => VenueDetailCubit(sl()));
  sl.registerLazySingleton(() => GetBookingByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBookingUseCase(sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl()));
  sl.registerFactory(() => BookingDetailCubit(sl()));
  sl.registerFactory(
    () => BookingActionCubit(
      updateBookingUseCase: sl(),
      cancelBookingUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetBookingsForCoordinatorUseCase(sl()));
  sl.registerLazySingleton(() => ApproveBookingUseCase(sl()));
  sl.registerLazySingleton(() => RejectBookingUseCase(sl()));
  sl.registerFactory(
    () => CoordinatorApprovalsCubit(
      getBookingsForCoordinatorUseCase: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerFactory(
    () => ApprovalActionCubit(
      approveBookingUseCase: sl(),
      rejectBookingUseCase: sl(),
    ),
  );
}
