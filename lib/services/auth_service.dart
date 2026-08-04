import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Listen to auth state changes (Logged in vs Anonymous vs Logged out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current User
  User? get currentUser => _auth.currentUser;

  // Sign in anonymously (For browsing only)
  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      print("Error signing in anonymously: $e");
    }
  }

  // Sign up with Email and Password (Required for posting)
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password
      );
      // Create a Tier 2 User Ledger Document in Firestore
      await _db.collection('users').doc(result.user!.uid).set({
        'isPremium': false,
        'totalPosts': 0,
        'totalReactionsReceived': 0,
        'email': email,
      });
      return result.user;
    } catch (e) {
      print("Error signing up: $e");
      return null;
    }
  }

  // Sign in with Email and Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, password: password
      );
      return result.user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    // Immediately sign back in anonymously so they can keep browsing
    await signInAnonymously();
  }
}
