using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

public class GameWorld : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField]
    WorldGameState worldState;

    string STR_KEY_DISTANCE_TO_GOAL_KEY = "STR_KEY_DISTANCE_TO_GOAL_KEY";
    string STR_KEY_ALIENS_COUNT = "STR_KEY_ALIENS_COUNT";
    string STR_KEY_PLAYER_LIFE = "STR_KEY_PLAYER_LIFE";
    string STR_WEAPON_PLAYER_USE = "STR_WEAPON_PLAYER_USE";
    void Start()
    {
        worldState = new WorldGameState();

        AddState(STR_KEY_DISTANCE_TO_GOAL_KEY, 0.0f);
        AddState(STR_KEY_ALIENS_COUNT, 0);
        AddState(STR_KEY_PLAYER_LIFE, 100);
        AddState(STR_WEAPON_PLAYER_USE, "None");
    }

    public void AddState(string nameKey, object state)
    {
        worldState.AddState(nameKey, state);
    }

    //Actualizar la distancia minima que al Goal (Gato) de los aliens Float
    public void UpdateDistanceToGoal()
    {
        float minDistance = float.MaxValue;


        if (worldState.states.ContainsKey("STR_KEY_DISTANCE_TO_GOAL_KEY"))
        {
            float distance = (float)worldState.states["STR_KEY_DISTANCE_TO_GOAL_KEY"];
            if (distance < minDistance)
            {
                minDistance = distance;
            }
        }

        worldState.SetState(STR_KEY_DISTANCE_TO_GOAL_KEY, minDistance);
    }

    //Actualizar la Cantidad de Aliens vivos que hay en el mapa.
    public void UpdateCantidadDeAliens(bool isAlive)
    {
        int aliveCount = 0;

        if (worldState.states.ContainsKey("STR_KEY_ALIENS_COUNT"))
        {
            if (isAlive)

                aliveCount++;
            else
                aliveCount--;

            worldState.SetState(STR_KEY_ALIENS_COUNT, aliveCount);
        }
    }

    ///Actualizar la Cantidad de Aliens que hay en el mapa.
    public void UpdateLifeOfPlayer(int newLife)
    {
        worldState.SetState(STR_KEY_PLAYER_LIFE, newLife);
    }
    ///Actualizar el arma que esta utilizando el Player
    public void UpdateWeaponUse(string newWeapon)
    {
        worldState.SetState(STR_WEAPON_PLAYER_USE, newWeapon);
    }

}
