import React, { useState, useEffect } from 'react';
import { 
  StyleSheet, 
  Text, 
  View, 
  TextInput, 
  TouchableOpacity, 
  ScrollView, 
  ActivityIndicator, 
  Animated 
} from 'react-native';

export default function App() {
  const [sender, setSender] = useState('PalmPay');
  const [message, setMessage] = useState('CRLF: Acct: 7063132091 Amt: ₦200,000.00 Cr Desc: Transfer from Simulation. Bal: ₦200,000.00');
  const [showAlert, setShowAlert] = useState(false);
  const [loading, setLoading] = useState(false);
  const [isPollingActive, setIsPollingActive] = useState(false);

  // Animation value for smooth fade-in/out banner alerts
  const [fadeAnim] = useState(new Animated.Value(0));

  useEffect(() => {
    let interval: NodeJS.Timeout;
    
    if (isPollingActive) {
      // Poll backend every 10 seconds
      interval = setInterval(() => {
        fetchLatestAlertFromServer();
      }, 10000);
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isPollingActive]);

  const triggerAlertAnimation = () => {
    setShowAlert(true);
    Animated.timing(fadeAnim, {
      toValue: 1,
      duration: 300,
      useNativeDriver: true,
    }).start();

    // Auto-hide after 5 seconds with fade out
    setTimeout(() => {
      Animated.timing(fadeAnim, {
        toValue: 0,
        duration: 300,
        useNativeDriver: true,
      }).start(() => setShowAlert(false));
    }, 5000);
  };

  const fetchLatestAlertFromServer = async () => {
    setLoading(true);
    try {
      // Connects directly to server endpoint to ping bank states
      const response = await fetch('https://api.ebanking-simulation.com/v1/get-latest-alert', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Client-Phone': '07063132091'
        }
      });
      
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }

      const data = await response.json();
      
      setSender(data.sender || 'PalmPay');
      setMessage(data.message || 'CRLF: Acct: 7063132091 Amt: ₦200,000.00 Cr Desc: Live Server Sync. Bal: ₦200,000.00');
      setLoading(false);
      triggerAlertAnimation();

    } catch (error) {
      console.warn('Live endpoint fallback to simulation loop:', error);
      
      // Fallback simulation layout matching local config requirements
      setTimeout(() => {
        setSender('PalmPay');
        setMessage(`CRLF: Acct: 7063132091 Amt: ₦200,000.00 Cr Desc: Ping Success. Bal: ₦200,000.00`);
        setLoading(false);
        triggerAlertAnimation();
      }, 800);
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.header}>Alert Simulation Engine</Text>

      {/* Simulated Notification Banner with Animation */}
      {showAlert && (
        <Animated.View style={[styles.banner, { opacity: fadeAnim }]}>
          <View style={styles.bannerHeaderRow}>
            <Text style={styles.bannerTitle}>{sender}</Text>
            <Text style={styles.bannerTime}>Just now</Text>
          </View>
          <Text style={styles.bannerBody}>{message}</Text>
        </Animated.View>
      )}

      <Text style={styles.label}>Sender Name</Text>
      <TextInput
        style={styles.input}
        value={sender}
        onChangeText={setSender}
        placeholder="Enter sender..."
      />

      <Text style={styles.label}>Alert Message Template</Text>
      <TextInput
        style={[styles.input, styles.textArea]}
        value={message}
        onChangeText={setMessage}
        multiline
        placeholder="Enter message body..."
      />

      <TouchableOpacity 
        style={styles.button} 
        onPress={fetchLatestAlertFromServer} 
        disabled={loading}
      >
        {loading ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.buttonText}>Manual Server Ping & Render</Text>
        )}
      </TouchableOpacity>

      <TouchableOpacity 
        style={[styles.button, isPollingActive ? styles.stopButton : styles.startButton]} 
        onPress={() => setIsPollingActive(!isPollingActive)}
      >
        <Text style={styles.buttonText}>
          {isPollingActive ? 'Stop Background Polling' : 'Start Background Polling'}
        </Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { 
    padding: 20, 
    justifyContent: 'center', 
    backgroundColor: '#f5f5f5', 
    flexGrow: 1 
  },
  header: { 
    fontSize: 22, 
    fontWeight: 'bold', 
    marginBottom: 20, 
    textAlign: 'center', 
    color: '#333' 
  },
  banner: { 
    backgroundColor: '#111827', 
    padding: 16, 
    borderRadius: 12, 
    marginBottom: 20, 
    elevation: 6, 
    shadowColor: '#000', 
    shadowOffset: { width: 0, height: 2 }, 
    shadowOpacity: 0.25, 
    shadowRadius: 3.84 
  },
  bannerHeaderRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    marginBottom: 6 
  },
  bannerTitle: { 
    color: '#10B981', 
    fontWeight: 'bold', 
    fontSize: 16 
  },
  bannerTime: { 
    color: '#9CA3AF', 
    fontSize: 12 
  },
  bannerBody: { 
    color: '#F3F4F6', 
    fontSize: 14, 
    lineHeight: 20 
  },
  label: { 
    fontSize: 14, 
    fontWeight: '600', 
    marginBottom: 5, 
    color: '#555' 
  },
  input: { 
    backgroundColor: '#fff', 
    borderWidth: 1, 
    borderColor: '#ddd', 
    borderRadius: 8, 
    padding: 12, 
    marginBottom: 15, 
    fontSize: 16 
  },
  textArea: { 
    height: 90, 
    textAlignVertical: 'top' 
  },
  button: { 
    backgroundColor: '#10B981', 
    padding: 15, 
    borderRadius: 8, 
    alignItems: 'center', 
    marginTop: 10 
  },
  startButton: {
    backgroundColor: '#3B82F6',
  },
  stopButton: {
    backgroundColor: '#EF4444',
  },
  buttonText: { 
    color: '#fff', 
    fontSize: 16, 
    fontWeight: 'bold' 
  },
});
