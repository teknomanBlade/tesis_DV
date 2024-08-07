using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorldGameState
{
    public Dictionary<string, object> states;

    public WorldGameState()
    {
        states = new Dictionary<string, object>();
    }

    public bool HasState(string key)
    {
        return states.ContainsKey(key);
    }

    public void AddState(string key, object value)
    {
        states.Add(key, value);
    }

    public void ModifyState(string key, object value)
    {
        if (states.ContainsKey(key))
        {
            Type currentType = states[key].GetType();
            Type valueType = value.GetType();

            if (currentType != valueType)
            {
                throw new InvalidOperationException($"Type mismatch");
            }

            if (value is int intValue)
            {
                states[key] = (int)states[key] + intValue;
            }
            else if (value is float floatValue)
            {
                states[key] = (float)states[key] + floatValue;
            }
            else if (value is bool boolValue)
            {
                states[key] = boolValue; // For bool, just replace the value
            }
            else if (value is string stringValue)
            {
                states[key] = stringValue; // For string, just replace the value
            }

            if (states[key] is int currentIntValue && currentIntValue <= 0)
            {
                RemoveState(key);
            }
            else if (states[key] is float currentFloatValue && currentFloatValue <= 0f)
            {
                RemoveState(key);
            }
        }
        else
        {
            AddState(key, value);
        }
    }

    public void RemoveState(string key)
    {
        if (states.ContainsKey(key))
            states.Remove(key);
    }

    public void SetState(string key, object value)
    {
        if (states.ContainsKey(key))
            states[key] = value;
        else
            states.Add(key, value);
    }

    public Dictionary<string, object> GetStates()
    {
        return states;
    }
}
