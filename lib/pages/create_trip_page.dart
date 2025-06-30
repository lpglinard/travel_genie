import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

import '../providers/challenge_providers.dart';
import '../providers/trip_service_provider.dart';
import '../providers/user_providers.dart';
import '../widgets/login_required_dialog.dart';

class CreateTripPage extends ConsumerStatefulWidget {
  const CreateTripPage({super.key});

  @override
  ConsumerState<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends ConsumerState<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    // Removed granular button tracking as per analytics strategy refactor

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: isStartDate ? DateTime.now() : _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before new start date, update end date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if user is authenticated
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Show login required dialog
        if (mounted) {
          await LoginRequiredDialog.show(context);
        }
        return;
      }
    } catch (e) {
      // Handle Firebase not initialized error - show login dialog
      if (mounted) {
        await LoginRequiredDialog.show(context);
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use the TripService from the provider to create the trip
      final tripService = ref.read(tripServiceProvider);

      final trip = await tripService.createTrip(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        isArchived: false,
      );

      // Track challenge progress for trip creation
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final challengeActions = ref.read(challengeActionsProvider);
          await challengeActions.markCompleted(user.uid, 'create_trip');
          debugPrint('[DEBUG_LOG] Create trip challenge marked as completed for user ${user.uid}');
        }
      } catch (e) {
        // Log error but don't prevent the trip creation success flow
        debugPrint('Error tracking create_trip challenge: $e');
      }

      ref
          .read(analyticsServiceProvider)
          .logCreateItinerary(
            tripId: trip,
            destination: _titleController.text.trim(),
          );

      if (mounted) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.tripCreatedSuccessfully,
            ),
          ),
        );
        context.go('/trips');
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(
          context,
        )!.failedToCreateTrip(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createNewTrip),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/trips'),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tripTitle,
                  hintText: AppLocalizations.of(context)!.tripTitleHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.tripTitleValidation;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tripDescription,
                  hintText: AppLocalizations.of(context)!.tripDescriptionHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Start date picker
              ListTile(
                title: Text(AppLocalizations.of(context)!.startDate),
                subtitle: Text(dateFormat.format(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 16),

              // End date picker
              ListTile(
                title: Text(AppLocalizations.of(context)!.endDate),
                subtitle: Text(dateFormat.format(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTrip,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(AppLocalizations.of(context)!.createTrip),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
